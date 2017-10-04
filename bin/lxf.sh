#!/bin/bash

### Altere esta constante, caso nao tenha escolhido o path default ###
# declare -r SRC_PATH="/usr/local/src"
declare -r SRC_PATH="/home/raul/dev/lxf/src"

source $SRC_PATH/lxf-colors.sh

declare file=$1
declare msg_error
declare NO_FILE
declare VERBOSE=0
declare QUIET="false"

declare now=$(date +%Y%m%d_%H%M%S)
declare tmp_file=/tmp/lXf_tEmP_fIlE_$now

function finish {
    # echo_info "Removendo $tmp_file"
    # rm -rf $tmp_file
    rm -rf /tmp/lXf_tEmP_fIlE_*
}
trap finish EXIT

usage () {
    [[ ! -z $msg_error ]] && echo_error "$msg_error"
    echo_info "Modo de uso do LXFramework"
    echo -e "Para arquivo 'lxf-file.sh', chame: ${green}lxf file${nc}"
    echo "Opts:"
    echo -e "${green}-n   | --no-file    ${nc}Desconsidera sessao [ FILE ] e [ FILE_SSH ] "
    echo -e "${green}-q   | --quiet      ${nc}Não exibe as informacoes"
    echo -e "${green}-v   | --verbose1   ${nc}Mostra arquivo compilado"
    echo -e "${green}-vv  | --verbose2   ${nc}Mostra retorno dos comandos LXC"
    echo -e "${green}-vvv | --verbose3   ${nc}Mostra comandos dentro do container"
    echo -e "${green}-h   | --help       ${nc}Exibe este help"
    echo_info "Ex.:"
    echo_command "lxf file -vv"
    
}

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]] 
then
    usage
    exit 0
fi


# Shifts arg <lxc-file>
shift

for args in $@ 
do
    if [[ ! $args =~ ^(-) ]]
    then
        msg_error="argumento invalido: $args"
        usage
        exit 1
    fi
    
    case $args in
        -h|--help)
            usage
            exit 0
        ;;
        -n|--no-file)
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
    esac
done


function get_file() {

    if [[ -z $file ]]
    then
        usage
        exit 1
    fi

    has_file=""
    file_to_source=""
    if [[ $file =~ ^(lxf-).*$ ]]
    then
        if [[ -f "$file" ]]
        then
            has_file="true"
            file_to_source="$file"
        elif [[ -f "${file}.sh" ]]
        then
            has_file="true"
            file_to_source="${file}.sh"
        fi        
    else
        if [[ -f "lxf-${file}" ]]
        then
            has_file="true"
            file_to_source="lxf-${file}"
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
        "DEST_PATH" \
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