#!/bin/bash
declare -r LOCAL_PATH="$(pwd)"
declare CONFIG
declare STORAGE_PATH
declare IMAGE
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
    [[ $CONTAINER_CLI == "true" ]] && return 0
    CONTAINER=$@
}
function PRIVILEGED () {
    [[ $PRIVILEGED_CLI == "true" ]] && return 0
    PRIVILEGED="true"
}
function NETWORK (){
    [[ $NETWORK_CLI == "true" ]] && return 0
    NETWORK=$@
}
function IPV4 (){
    [[ $IPV4_CLI == "true" ]] && return 0    
    IPV4=$@
}
function USER_NAME (){
    [[ $USER_NAME_CLI == "true" ]] && return 0        
    USER_NAME=$@
}
function USER_GROUP (){ 
    [[ $USER_GROUP_CLI == "true" ]] && return 0            
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
    [[ $FROM_VALUE_CLI == "true" ]] && return 0    
    FROM_VALUE=$@
}
function ENV () {
    [[ $ENV_VALUE_CLI == "true" ]] && return 0        
    ENV_VALUE="$@"
}