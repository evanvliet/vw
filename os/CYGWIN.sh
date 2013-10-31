#!/bin/bash
# +
# For windows cygwin. Nice of cygwin to provide /dev/clipboard.
# -
browse() { cmd /c start iexplore.exe "$@" ; } # web
gdiff() { wmerge $1 $2 & } # gui diff
gdir() { cmd /c start . ; } # gui dir
gedit() { cmd /c start notepad $1 ; } # gui editor
wcopy() { cat - > /dev/clipboard ; } # copy to clipboard
wpaste() { cat /dev/clipboard ; } # paste from clipboard
set -o vi
shopt -s checkwinsize
