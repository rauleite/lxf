#!/bin/bash
cyan='\e[36m'
yellow='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
light_gray='\e[37m'
gray='\e[90m'
ligh_green='\e[92m'
light_red='\033[1;31m'
brown='\033[0;33m'
nc='\033[0m' # No Color

function echo_info () {
    # [[ $VERBOSE -lt 1 ]] && return 0
    [[ $QUIET != "true" ]] && echo -e "${gray}$*${nc}"
}
function echo_warning () {
    echo -e "${yellow}$*${nc}"
}
function echo_quest () {
    echo -e "${cyan}$*${nc}"
}
function echo_command () {
    echo -e "${green}$*${nc}"
}
function echo_error () {
    echo -e "${red}$*${nc}"
}
function echo_code () {
    echo -e "${green}$*${nc}"
}