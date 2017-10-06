#!/bin/bash
brown='\033[0;33m'
red='\033[1;31m'
cyan='\e[36m'
green='\e[32m'
blue='\e[34m'
light_gray='\e[37m'
gray='\e[90m'
ligh_green='\e[92m'
nc='\033[0m' # No Color

function echo_info () {
    echo -e "${gray}$*${nc}"
}
function echo_quest () {
    echo -e "${cyan}$*${nc}"
}
function echo_command () {
    echo -e "${cyan}$*${nc}"
}
function echo_error () {
    echo -e "${red}$*${nc}"
}
function echo_code () {
    echo -e "${green}$*${nc}"
}

until_host_nc () {
    until nc -vzw 2 $1 22; do sleep 1; done    
}
until_host_ping () {
    until ping -c1 $1; do sleep 1; done
}
update () {
    echo_info 'Conectando: archive.ubuntu.com'
    until ping -c1 archive.ubuntu.com; do sleep 1; done
    until nc -vzw 2 archive.ubuntu.com 22; do sleep 1; done    

    echo_info "Ok"
    echo_info 'Conectando: security.ubuntu.com'    

    until ping -c1 security.ubuntu.com; do sleep 1; done    
    until nc -vzw 2 security.ubuntu.com 22; do sleep 1; done        
    echo_info "Ok"
    sudo apt-get -y upgrade
    sudo apt-get update
    sudo apt-get -y upgrade

}
add_ppa () {
    grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep $1 > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo_info "[ PPA ] + $1"
        sudo add-apt-repository ppa:$1 -y
    return 0 
    else
        echo_info '[ PPA ] Ja existe'
        return 1
    fi
}
exists () {
    which $1 &>/dev/null
}

function instala_netdata () {
    # Netdata
    exists "netdata"
    if [[ $? != 0 ]]
    then
        sudo apt-get install -y zlib1g-dev
        sudo apt-get install -y uuid-dev
        sudo apt-get install -y libmnl-dev
        sudo apt-get install -y gcc
        sudo apt-get install -y make
        sudo apt-get install -y git
        sudo apt-get install -y autoconf
        sudo apt-get install -y autoconf-archive
        sudo apt-get install -y autogen
        sudo apt-get install -y automake
        sudo apt-get install -y pkg-config
        sudo apt-get install -y curl
        
        cd ~ && \
            git clone https://github.com/firehol/netdata.git --depth=1 && \
            cd netdata && \
                sudo ./netdata-installer.sh --dont-wait
    fi
}

function essentials () {

    echo_code "Rodando com usuario: $USER"
    update
    ### ifconfig ###
    sudo apt-get install -y net-tools 
    ### add-apt-repository ###
    sudo apt-get install -y software-properties-common
    ### essentials ###
    sudo apt-get install -y wget
    sudo apt-get install -y git
    sudo apt-get install -y nano
    sudo apt-get install -y curl
    sudo apt-get install -y ufw
    sudo apt-get install -y openssh-server
    # instala_netdata
}
