#!/bin/bash
# +
# Startup script meant to be sourced in .bashrc. It, in turn, sources
# the files known to the `vw` package.
# -
pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
export VW_DIR="$PWD"
source base/vw.sh # vw function
for i in $(vw --files)
do
    source $i
done
popd &> /dev/null
