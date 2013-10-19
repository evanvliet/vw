#!/bin/bash
# vw profile

export VW_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
. "$VW_DIR/base/vw.sh" # vw function
for i in $(vw --files)
do
    . "$VW_DIR/$i"
done
