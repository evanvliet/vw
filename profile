#!/bin/bash
# +
# Startup script meant to be sourced in .bashrc. It, in turn, sources
# the files known to the `vw` package.
# -
pushd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null
export VW_DIR="$PWD"
source base/vw.sh # vw functions
for vw_file in $(vwfiles)
do
    source $vw_file
done
unset vw_file
popd > /dev/null
