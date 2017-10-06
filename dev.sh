#!/bin/bash
### Altere estas constantes, caso queira mudar o local ###
source ./src_install.sh

for i in ${src_files[@]}
do
    # sudo cp -vrf $src_path/$i       $src_dest
    sudo ln -vfs $src_path/$i  $src_dest
    sudo chown $USER    $src_dest/$i
    sudo chmod 664      $src_dest/$i
done 

sudo ln -vfs $bin_path/$bin_file $bin_dest/lxf

sudo chown $USER    $bin_dest/lxf
sudo chmod 774      $bin_dest/lxf
