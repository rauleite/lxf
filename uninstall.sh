#!/bin/bash
source ./src_install.sh

for i in ${src_files[@]}
do
    sudo rm -vf $src_dest/$i    
done 

sudo rm -vf $bin_dest/lxf
