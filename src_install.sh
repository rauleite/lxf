#!/bin/bash
declare -r SRC_PATH="/usr/local/src"
declare -r BIN_PATH="/usr/local/bin"

src_path="$(pwd)/src"
bin_path="$(pwd)/bin"
src_files=(\
    "lxf-colors.sh" \
    "lxf-lib-dinam.sh" \
    "lxf-lib-init.sh" \
    "lxf-lib.sh"\
)

bin_file="lxf.sh"
src_dest="$SRC_PATH"
bin_dest="$BIN_PATH"