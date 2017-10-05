#!/bin/bash
declare -r LOCAL_PATH="$(pwd)"
declare CONFIG
declare CONTAINER
declare STORAGE_PATH
declare IMAGE
declare IPV4
declare NETWORK
declare PRIVILEGED
declare USER_NAME
declare USER_GROUP

declare FROM_VALUE
declare ENV_VALUE
declare VOLUME_VALUE
declare FILES_VALUE
declare FILES_SSH_VALUE

### FRAMEWORK GLOBAL CONSTS ###
function CONFIG (){
    # Substitui \s por =
    config=$(echo -E "$@" | sed -r 's/(\s*)?[_=]?\s+/_/g')
    CONFIG=(${CONFIG[@]} "$config")
}
function CONTAINER (){ 
    CONTAINER=$@
}
function PRIVILEGED () {
    PRIVILEGED="true"
}
function NETWORK (){ 
    NETWORK=$@
}
function IPV4 (){ 
    IPV4=$@
}
function USER_NAME (){ 
    USER_NAME=$@
}
function USER_GROUP (){ 
    USER_GROUP=$@
}
function VAR (){ 
    echo_info "[ VAR ] $@"
    export $1="$2" 
}
function STORAGE_PATH () {
    echo_info "[ STORAGE_PATH ] $@"
    STORAGE_PATH=$@
}
function SOURCE () {
    source $@
}

### POS INIT ###
function FROM () {
    FROM_VALUE=$@
}
function ENV () {
    ENV_VALUE="$@"
}