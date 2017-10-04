#!/bin/bash
### Altere estas constantes, caso queira mudar o local ###
SRC_PATH="/usr/local/src"
BIN_PATH="/usr/local/bin"

src_path="./src"
bin_path="./bin"
src_files=(\
    "lxf-colors.sh" \
    "lxf-lib-dinam.sh" \
    "lxf-lib-init.sh" \
    "lxf-lib.sh"\
)

bin_file="lxf.sh"
src_dest="$SRC_PATH"
bin_dest="$BIN_PATH"

for i in ${src_files[@]}
do
    sudo rm -vf $src_dest/$i    
done 

sudo rm -vf $bin_dest/lxf
