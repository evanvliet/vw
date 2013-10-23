#!/bin/bash
: << ''
For windows cygwin. Nice of cygwin to provide /dev/clipboard.

browse() { cmd /c start iexplore.exe "$@" ; } # web
gdiff() { wmerge $1 $2 & } # gui diff
gdir() { cmd /c start . ; } # gui dir
gedit() { cmd /c start notepad $1 ; } # gui editor
wcopy() { cat - > /dev/clipboard ; } # copy to clipboard
wpaste() { cat /dev/clipboard ; } # paste from clipboard
tput() { test .$1 = .cols && echo 80 ; } # since cygwin has no tput
vw_key() # machine dependent key
{
    cmd /c vol $HOMEDRIVE | grep Serial | openssl dgst -md5 | sed -e s/.*=.//
}
