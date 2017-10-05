#!/bin/bash
### Altere estas constantes, caso queira mudar o local ###
declare -r SRC_PATH="/usr/local/src"
declare -r BIN_PATH="/usr/local/bin"

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

# src_dest="./teste/src"
# bin_dest="./teste/bin"

for i in ${src_files[@]}
do
    sudo cp -vrf $src_path/$i    $src_dest
    sudo chown $USER            $src_dest/$i
    sudo chmod 664              $src_dest/$i
done 

sudo cp -vrf $bin_path/$bin_file $bin_dest/lxf

sudo chown $USER    $bin_dest/lxf
sudo chmod 774      $bin_dest/lxf
