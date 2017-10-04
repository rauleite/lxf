#!/bin/bash
### INIT ###
function FROM_INIT () {
    echo_info "[ FROM ] $@"
    IMAGE=$1
    create_container
    post_from
}
function ENV_INIT () {
    exists_container $CONTAINER
    if [[ $? != 0 ]]
    then
        echo_error "Container não encontrado. Certificar que comando FROM, esteja acima de ENV, EXEC, COPY etc"
        exit 1
    fi
    echo_info "[ ENV ] $@"

    while true
    do
        [[ $# == 0 ]] && break
        exec_cmd_user "sudo mkdir -p $1"
        exec_cmd_user "sudo chown $USER_NAME:$USER_NAME $1"
        exec_cmd_user "sudo chmod g+s $1"
        shift
    done
}
declare is_started="false"
init () {
    [[ $is_started == "true" ]] && return 0
    [[ ! -z $FROM_VALUE ]]      && FROM_INIT $FROM_VALUE
    [[ ! -z $DEST_PATH ]]       && DEST_PATH=$DEST_PATH/$CONTAINER/rootfs
    [[ ! -z $ENV_VALUE ]]       && ENV_INIT $ENV_VALUE
    # [[ ! -z $FILES_VALUE ]]     && FILES_INIT $FILES_VALUE
    # [[ ! -z $FILES_SSH_VALUE ]] && FILES_SSH_INIT $FILES_SSH_VALUE
    # [[ ! -z $VOLUME_VALUE ]]    && VOLUME_INIT $VOLUME_VALUE
    is_started="true"
}

### DINAMICO ###
function FILES () {
    init
    files 'default' $@
}
function FILES_SSH () {
    init        
    read_ip
    files 'ssh' $@
}
function VOLUME () {
    init        
    echo_info "[ VOLUME ] $@"
    volume "$@"
    
}
function HOST_EXEC () {
    init
    echo_info "[ HOST_EXEC ] $@"
    # $@
    cmd=$@
    # echo_info $cmd && /bin/bash -c "$cmd"
    /bin/bash -c "$cmd"
}
function COPY_SSH () {
    init
    local -r src=$1; shift
    local -r dest=$1; shift
    read_ip
    copy "ssh" "$USER_NAME@$IPV4:$dest" "$src"
}
function COPY () {
    init
    local -r src=$1; shift        
    local -r dest=$1; shift
    copy "default" "$dest" "$src"
}
function EXEC () {
    init
    exec_cmd_user "$@"
}
function EXEC_SSH () {
    init
    exec_cmd_user_ssh "$@"
}