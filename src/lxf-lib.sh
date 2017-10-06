#!/bin/bash
declare -r VERBOSE_INFO=1
declare -r VERBOSE_LXC=2
declare -r VERBOSE_CONTAINER=3

### TRAP ###
function ct_restart() {
        echo ""    
        echo_info "Finalizando"
        lxc restart $CONTAINER
        echo -e "${nc}"
        
        exit 1
}
trap ct_restart INT

### EXEC ###
function exec_cmd_user () {
    echo_info "[ EXEC ] $@"
    # cmd=$@
    # lxc exec $CONTAINER -- sudo -H -u $USER_NAME /bin/bash -c "cd ~/ && $@"
    # lxc exec $CONTAINER -- sudo -H -u $USER_NAME /bin/bash -c "cd ~/ && echo \"$@\" && $@"
    if [[ $VERBOSE -lt $VERBOSE_CONTAINER ]]
    then
        lxc exec $CONTAINER -- sudo -H -u $USER_NAME /bin/bash -c "cd ~/ && $@"
    else
        echo_command "lxc exec $CONTAINER -- sudo -H -u $USER_NAME /bin/bash -c \"cd ~/ && echo \"$@\" && $@\""
        echo -e "${blue}"
        lxc exec $CONTAINER -- sudo -H -u $USER_NAME /bin/bash -c "cd ~/ && echo \"$@\" && $@"        
        echo -e "${nc}"        
    fi      
}
function exec_cmd_user_ssh () {
    echo_info "[ EXEC_SSH ] $USER_NAME@$IPV4 $@"
    
    ssh $USER_NAME@$IPV4 "$@"

}

### UTILS ###
function until_host () {
    echo "Conectando: $1"
    if [[ $VERBOSE -lt $VERBOSE_LXC ]]
    then
        exec_cmd_user "until ping -c1 $1 &>/dev/null; do sleep 1; done"
    else
        exec_cmd_user "until ping -c1 $1; do sleep 1; done"
    fi

    sleep 3
    echo "Ok"
}
function exists () {
    if [[ $VERBOSE -lt $VERBOSE_LXC ]]
    then
        exec_cmd_user "which $1 &>/dev/null"
    else
        exec_cmd_user "which $1"
    fi
}
function exists_user () {
    if [[ $VERBOSE -lt $VERBOSE_LXC ]]
    then
        exec_cmd_user "id -u $1 &>/dev/null"
    else
        exec_cmd_user "id -u $1"
    fi
}
function exists_container () {
    if [[ $VERBOSE -lt $VERBOSE_LXC ]]
    then
        lxc config show $1 &>/dev/null
    else
        echo_command "lxc config show $1"
        lxc config show $1
    fi
}
function copy () {
    local -r type_copy=$1; 
    shift
    local dest="$1"
    shift
    local src="$@"
    shift

    # echo "type_exec $type_exec"
    # echo "dest $dest"
    # echo "src $src"

    if [[ $type_copy == "ssh" ]]
    then
        echo_info "[ COPY_SSH ] $src $dest"
        rsync -r -a -e "ssh" --chown=$USER_NAME:$USER_GROUP --rsync-path="sudo rsync" "$src" "$USER_NAME@$IPV4:$dest"
    else
        echo_info "[ COPY ] $src $dest"     
        # sudo rsync -r -a --chown=$USER_NAME:$USER_NAME --rsync-path="sudo rsync" $@
        sudo rsync -r --rsync-path="sudo rsync" $src $DEST_PATH$dest
        for i in $src
        do
            file_name="$(basename $i)"
            exec_cmd_user "sudo chown $USER_NAME:$USER_GROUP $dest/$file_name"
        done
    fi
    
}
function files () {
    if [[ $NO_FILE == "true" ]]
    then
        echo_info "[ NO FILES ]"
        return 0        
    fi
    local dest
    local src
    local -r type_exec="$1"; 
    shift
    local -r file_to_exec="$(basename $1)"; # Sem shift

    while true
    do  
        # Ultimo arg
        if [[ $# == 1 ]]
        then
            dest="$1"
            shift
            break
        fi
        src="$src $1"
        shift
    done

    # local cmd_dir="sudo rm -rf $dest && sudo mkdir $dest"
    local cmd_dir="mkdir -p $dest"
    local cmd_file="cd $dest && $dest/$file_to_exec"

    if [[ $type_exec == "ssh" ]]
    then
        echo_info "[ FILES_SSH ] $src $dest"
        exec_cmd_user_ssh "$cmd_dir"          
        copy  "ssh" "$dest" "$src" 
        exec_cmd_user_ssh "$cmd_file"
    else
        echo_info "[ FILES ] $src $dest"    
        exec_cmd_user "$cmd_dir"
        copy "default" "$dest" "$src"
        exec_cmd_user "$cmd_file"
    fi

}
function volume () {
    local src=$1
    local dest=$2
    local src_filename
    local dest_filename

    # SRC Dirname sendo file ou diretorio
    if [[ -d $src ]]
    then
        src_dirname=$src
    elif [[ -f $src ]]
    then
        src_dirname=$(dirname $src)            
        src_filename=$(basename $src)
    fi

    # DEST Dirname sendo file ou diretorio
    if [[ -d $dest ]]
    then
        dest_dirname=$dest
    elif [[ -f $dest ]]
    then
        dest_dirname=$(dirname $dest)
        dest_filename=$(basename $dest)
    fi

    device_name=$src_dirname

    existing_src=$(lxc config device get $CONTAINER $device_name source 2> /dev/null)

    # Diretorio
    if [[ -d $src ]]
    then
        if [[ "$existing_src" != "$src" ]]
        then
            exec_cmd_user "mkdir -p $dest"
            if [[ $VERBOSE -lt $VERBOSE_LXC ]]
            then
                lxc config device add $CONTAINER $device_name disk source=$src path=$dest &> /dev/null
            else
                echo_command "lxc config device add $CONTAINER $device_name disk source=$src path=$dest"
                lxc config device add $CONTAINER $device_name disk source=$src path=$dest  
            fi         
        else
            echo_info "Source: $src ja atribuido a Volume"
            # exit 1
        fi
    # Arquivo
    elif [[ -f $src ]]
    then
        # Se device ainda nao existe
        if [[ "$existing_src" != "$src" ]]
        then
            local home="/home/$USER_NAME"
            [[ "$USER_NAME" == "root" ]] && home="/root"

            # Repete estrutura do src no container (em ~/.lxf)
            dest_dirname="$home/.lxf/volume-file/$src_dirname"
            exec_cmd_user "mkdir -p $dest_dirname"
            if [[ $VERBOSE -lt $VERBOSE_LXC ]]
            then
                lxc config device add $CONTAINER $device_name disk source=$src_dirname path=$dest_dirname &> /dev/null
            else
                echo_command "lxc config device add $CONTAINER $device_name disk source=$src_dirname path=$dest_dirname"
                lxc config device add $CONTAINER $device_name disk source=$src_dirname path=$dest_dirname
            fi            

            exec_cmd_user "sudo ln -f -s $dest_dirname/$src_filename $dest"
        # Caso device exista
        else
            exec_cmd_user "sudo ln -f -s $dest_dirname/$src_filename $dest"
        fi
    else
        echo_error "$src nao e valido"
        exit 1
    fi
}

### UPDATE, UPGRADE, INSTALL ###
function update () {
    echo_info 'Espedando archive.ubuntu.com'
    lxc exec $CONTAINER -- bash -c 'until nc -vzw 2 archive.ubuntu.com 22; do sleep 2; done && until nc -vzw 2 security.ubuntu.com 22; do sleep 2; done'
    echo_info 'Ok'    
    echo_info 'Updating...'    
    lxc exec $CONTAINER -- bash -c "apt-get update"    
}
function upgrade () {
    echo_info 'Upgrading...'    
    lxc exec $CONTAINER -- bash -c "apt-get -y upgrade"
}
function install () {
    echo_info "install: $@"
    lxc exec $CONTAINER -- bash -c "apt-get -y install $@"
}

### CREATING / LAUNCHING UTILS ###
function read_container () {
    if [[ -z $CONTAINER ]]
    then
        echo_quest "Nome de um novo, ou existente CONTAINER."
        read ct_name_read
        [[ -z $ct_name_read ]] && echo_error "Container deve ter um nome" && exit 1
        CONTAINER=$ct_name_read
    fi
}
function read_user () {
    if [[ -z $USER_NAME ]]
    then
        echo_quest "Nome do USER existente, para assumir comandos em $CONTAINER"
        read user_name_read

        [[ -z $user_name_read ]] && exit 1
        USER_NAME=$user_name_read
    fi
}
function read_ip () {
    [[ ! -z $IPV4 ]] && return 0
    until_host $CONTAINER

    lxc list $CONTAINER
    echo_quest "IP de $CONTAINER"
    read ip_read

    [[ -z $ip_read ]] && ct_restart && exit 1
    IPV4=$ip_read
    echo "read_ip --> $IPV4"
}
function stop_start_container () {
    if [[ $VERBOSE -lt $VERBOSE_LXC ]]
    then
        lxc stop $CONTAINER &>/dev/null
        lxc start $CONTAINER &>/dev/null
    else
        echo_command "lxc stop $CONTAINER"            
        lxc stop $CONTAINER
        echo_command "lxc start $CONTAINER"                        
        lxc start $CONTAINER
    fi
}
function attach_network () {
    if [[ -z $NETWORK ]]
    then
        lxc network list
        echo_quest "Nome da Conexao Bridge."
        read network_read
        [[ -z $network_read ]] && exit 1
        NETWORK=$network_read
    fi

    lxc network attach $NETWORK $CONTAINER
    
    ### Adiciona IP dinamico caso tenha informado IPV4 ### 
    if [[ ! -z $IPV4 ]]
    then
        echo_command "IPV4 $IPV4"
        stop_start_container
        lxc config device set $CONTAINER $NETWORK ipv4.address $IPV4
    fi
}
function add_configs () {
    stop_start_container
    for i in ${CONFIG[@]}
    do
        config=$(echo -e "$i" | sed -r 's/_/ /g')
        lxc config $config
    done
} 
function post_from () {
    read_user

    exists_user $USER_NAME
    [[ $? != "0" ]] && echo_error "Usuario $USER_NAME inexistente" && read_user
    echo_info "[ USER ] $USER_NAME:$USER_GROUP"
    # attach_network
    # install_rsync
    
}
function create_container () {
    read_container
    # Network
    exists_container $CONTAINER
    if [[ $? == "0" ]]
    then
        echo_info "Usando o container $CONTAINER, existente."
    else
        echo_info "Criando container $CONTAINER"
        if [[ $PRIVILEGED == "true" ]]
        then
            echo_info "ALIAS: PRIVILEGED mode"

            if [[ $VERBOSE -lt $VERBOSE_LXC ]]
            then
                lxc launch $IMAGE $CONTAINER &>/dev/null
            else
                echo_command "lxc launch $IMAGE $CONTAINER"
                lxc launch $IMAGE $CONTAINER 
            fi
        else
            echo_info "ALIAS: UNPRIVILEGED mode"
            if [[ $VERBOSE -lt $VERBOSE_LXC ]]
            then
                lxc launch $IMAGE $CONTAINER &>/dev/null
            else
                echo_command "lxc launch $IMAGE $CONTAINER"
                lxc launch $IMAGE $CONTAINER
            fi
        fi
        attach_network
        add_configs
        
        stop_start_container               
    fi
}
function install_rsync () {
    exists 'rsync'
    if [[ $? != 0 ]]
    then
        echo_quest "Voce parece nao ter rsync, deseja instalar? [Yn]"
        read install

        [[ $install  =~ ^[nN][[:blank:]]*$ ]] && ( ct_restart && exit 1 )

        sudo apt-get -y install rsync
    fi
}
