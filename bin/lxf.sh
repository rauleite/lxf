#!/bin/bash

### Altere esta constante, caso nao tenha escolhido o path default ###
declare -r SRC_PATH="/usr/local/src"
# declare -r SRC_PATH="/home/raul/dev/lxf/src"

source $SRC_PATH/lxf-colors.sh

declare file=$1
declare msg_error
declare NO_FILE
declare VERBOSE=0
declare QUIET="false"

declare now=$(date +%Y%m%d_%H%M%S)
declare tmp_file=/tmp/lXf_tEmP_fIlE_$now

declare CONTAINER
declare CONTAINER_CLI="false"
declare IPV4
declare IPV4_CLI="false"
declare NETWORK
declare NETWORK_CLI="false"
declare FROM_VALUE
declare FROM_VALUE_CLI="false"
declare ENV_VALUE
declare ENV_VALUE_CLI="false"
declare PRIVILEGED
declare PRIVILEGED_CLI="false"
declare USER_NAME
declare USER_NAME_CLI="false"
declare USER_GROUP
declare USER_GROUP_CLI="false"

function finish {
    # echo_info "Removendo $tmp_file"
    # rm -rf $tmp_file
    rm -rf /tmp/lXf_tEmP_fIlE_*
}
trap finish EXIT

# Shifts arg <lxc-file>
shift

usage () {
    [[ ! -z $msg_error ]] && echo_error "$msg_error"
    echo -e "${blue}"
    echo -e "Opts:"
    echo -e "${green}-c   --container         ${yellow}<nome>${nc}${blue} do container            | CONTAINER"
    echo -e "${green}-n   --network           ${yellow}<nome>${nc}${blue} do device               | NETWORK"
    echo -e "${green}-u   --user              ${yellow}<nome>${nc}${blue} do usuario              | USER_NAME"
    echo -e "${green}-g   --group             ${yellow}<nome>${nc}${blue} do grupo do usuario     | USER_GROUP"
    echo -e "${green}-e   --env               ${yellow}<path>${nc}${blue} ou ${yellow}\"<path> [<path2>]\"${nc}${blue}   | ENV"
    echo -e "${green}-f   --from              ${yellow}<nome>${nc}${blue} da imagem               | FROM"
    echo -e "${green}-cpr --conf-privileged   ${yellow}<true>${nc}${blue} ou ${yellow}<false>${nc}${blue}              | PRIVILEGED"
    echo -e "${green}-cip --conf-ipv4         ${yellow}<numero>${nc}${blue} do ip fixo            | IPV4"
    echo -e "${green}-nf  --no-file           ${nc}${blue}Desconsidera [ FILE ]"
    echo -e "${green}-q   --quiet             ${nc}${blue}Não exibe as informacoes"
    echo -e "${green}-v   --verbose1          ${nc}${blue}Mostra arquivo compilado"
    echo -e "${green}-vv  --verbose2          ${nc}${blue}Mostra retorno dos comandos LXC"
    echo -e "${green}-vvv --verbose3          ${nc}${blue}Mostra comandos dentro do container"
    echo -e "${green}-h   --help              ${nc}${blue}Exibe este help"
    echo ""
    echo_info "Exemplos:"
    echo_info "----------"
    echo_info "lxf file"
    echo_info "lxf file -nf"
    echo_info "lxf file -vv -cip 10.99.125.11"
    echo_info "lxf file -c mycontainer --conf-privileged true"
    echo -e ${nc}
    
}
# has_arg="false"
while true; do
    # Se existe e nao comeca com -
    if [[ ! -z $1 && ! $1 =~ ^(-) ]]; then
        echo opa
        msg_error="argumento invalido: $1"
        usage
        exit 1
    fi
    
    case $1 in
        -h|--help)
            usage
            exit 0
        ;;
        -c|--container)
            shift
            CONTAINER=$1
            CONTAINER_CLI="true"
        ;;
        -n|--network)
            shift
            NETWORK=$1
            NETWORK_CLI="true"
        ;;
        -u|--user)
            shift
            USER_NAME=$1
            USER_NAME_CLI="true"
        ;;
        -g|--group)
            shift
            USER_GROUP=$1
            USER_GROUP_CLI="true"
        ;;
        -e|--env)
            shift
            ENV_VALUE=$1
            ENV_VALUE_CLI="true"
        ;;
        -f|--from)
            shift
            FROM_VALUE=$1
            FROM_VALUE_CLI="true"
        ;;
        -cpr|--conf-privileged)
            shift
            PRIVILEGED=$1
            PRIVILEGED_CLI="true"
        ;;
        -cip|--conf-ipv4)
            shift
            IPV4=$1
            IPV4_CLI="true"
        ;;
        -nf|--no-file)
            NO_FILE="true"
        ;;
        -v|--verbose1)
            VERBOSE=1
        ;;
        -vv|--verbose2)
            VERBOSE=2
        ;;
        -vvv|--verbose3)
            VERBOSE=3
        ;;
        -q|--quiet)
            QUIET="true"
        ;;
        *)
            # Se ha argumento, mas nao bate com nenhum
            if [[ ! -z $1 ]]; then
                msg_error="argumento invalido: $1"
                usage
                exit 1
            fi
        ;;
    esac
    shift
    [[ $# == 0 ]] && break
done

function get_file() {

    if [[ -z $file ]]
    then
        usage
        exit 1
    fi

    # Define o comando, como nome do container, caso nao tenha passado -c.
    # Mas considerara CONTAINER, caso esteja setado no arquivo
    if [[ -z $CONTAINER ]]; then
        # Remove . - lxd- .sh
        local name=$(echo $file | sed -r 's/[\.sh]|[lxf\-]|[\.]+|[\-]+|[\_]+//g')
        CONTAINER=$name
    fi

    ### Seta user e group como root, caso nao tenha ### 
    if [[ -z $USER_NAME ]]; then
        USER_NAME='root'
    fi

    if [[ -z $USER_GROUP ]]; then
        USER_GROUP='root'
    fi
    
    has_file=""
    file_to_source=""
    if [[ $file =~ ^(lxf-).*$ ]]
    then
        # Nome completo 
        if [[ -f "$file" ]]
        then
            has_file="true"
            file_to_source="$file"
        # Sem sh
        elif [[ -f "${file}.sh" ]]
        then
            has_file="true"
            file_to_source="${file}.sh"
        fi        
    else
        # Sem lxf-
        if [[ -f "lxf-${file}" ]]
        then
            has_file="true"
            file_to_source="lxf-${file}"
        # Sem sh e lxf-
        elif [[ -f "lxf-${file}.sh" ]]
        then
            has_file="true"
            file_to_source="lxf-${file}.sh"
        fi
    fi

    if [[ -z $has_file ]]
    then
        msg_error="Arquivo não encontrado"
        usage
        exit 1
    fi
}
function lexico () {
    ### Analise de lexico ###
    keywords=( \
        "CONFIG" \
        "CONTAINER" \
        "COPY" \
        "COPY_SSH" \
        "ENV" \
        "EXEC" \
        "EXEC_SSH" \
        "FILES" \
        "FILES_SSH" \
        "FROM" \
        "HOST_EXEC" \
        "IPV4" \
        "NETWORK" \
        "PRIVILEGED" \
        "SOURCE" \
        "STORAGE_PATH" \
        "USER_NAME" \
        "USER_GROUP" \
        "VAR" \
        "VOLUME" \
    )

    echo '#!/bin/bash' >> $tmp_file

    readarray lines_file < $file_to_source
    
    local file_size=${#lines_file[@]}
    local file_length=$(( file_size - 1 ))

    local keywords_size=${#keywords[@]}
    local keywords_length=$(( keywords_size - 1 ))

    for (( i=0; i<=$file_length; i++ ))
    do 
        line=${lines_file[$i]}
        # line Trim
        line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        # Aceita '\' como que continua na linha de baixo
        last_char=${line##* }
        if [[ $last_char == "\\" ]]
        then
            next=$(( i + 1 ))
            # Remove \ seguida de espacos
            line=$(echo "$line" | sed -e 's/\\\s[\s]*//g')
            # Remove \ no fim da linha
            line=$(echo "$line" | sed -e 's/\\$//g')
            lines_file[$next]="$line${lines_file[$next]}"
            continue
        fi
        # Keyword do arquivo
        file_key_word=$(echo "$line" | awk '{print $1;}')

        # word Trim
        file_key_word="$(echo -e "${file_key_word}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # Ignora linha em branco ou comentarios
        [[ -z $file_key_word || ${file_key_word:0:1} == "#" ]] && continue

        # Checa Keywords das linhas validas
        for (( j=0; j<=$keywords_length; j++ ))
        do
            keyword=${keywords[j]}
            if [[ $file_key_word =~ ^($keyword)$ ]]
            then
                # No caso de HOST_EXEC e EXEC, coloca backslash nas aspas
                if [[ $file_key_word =~ ^(HOST_EXEC)$ ]]
                then
                    # Remove keyword HOST_EXEC                    
                    line=$(echo "$line" | sed -e 's/HOST_EXEC\s*//g')
                    # Substitui aspas
                    line=$(echo "$line" | sed -e 's/"/\\\"/g')
                    # line=$(echo "$line" | sed -e "s/'/\\\'/g")
                    # Devolve keyword HOST_EXEC                    
                    line="HOST_EXEC "\"$line\"
                elif [[  $file_key_word =~ ^(EXEC)$  ]]
                then
                    # Remove keyword EXEC
                    line=$(echo "$line" | sed -e 's/EXEC\s*//g')
                    # Substitui aspas                    
                    line=$(echo "$line" | sed -e 's/"/\\\"/g')
                    # line=$(echo "$line" | sed -e "s/'/\\\'/g")
                    # Devolve keyword EXEC
                    line="EXEC "\"$line\"
                fi
                [[ $VERBOSE -ge 1 ]] && echo_info $line
                echo $line >> $tmp_file
                
                break
            fi
            if [[ $j == $keywords_length ]]
            then
                echo_error "Keyword '${file_key_word}' desconhecido"
                exit 1
            fi
        done
    done
}

get_file
lexico

source $SRC_PATH/lxf-lib.sh
source $SRC_PATH/lxf-lib-init.sh
source $SRC_PATH/lxf-lib-dinam.sh
source $tmp_file
# source $file_to_source

finish