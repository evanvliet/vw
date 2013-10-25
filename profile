#!/bin/bash
<< 'qp'
Startup script meant to be sourced in .bashrc. It, in turn, sources
the files known to the `vw` package.
qp

export VW_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$VW_DIR/base/vw.sh" # vw function
for i in $(vw --files)
do
    source "$VW_DIR/$i"
done
