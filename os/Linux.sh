#!/bin/bash
: << ''
For linux.

browse() # web
{
    ( nohup xdg-open $* & ) &> /dev/null
}
gdiff() { meld $* 2> /dev/null . ; } # gui diff
gdir() { nautilus 2> /dev/null . ; } # gui files
gedit() { /usr/bin/gedit -b $1 ; } # gui editor
wcopy() { xsel -ib 2> /dev/null || cat - > $s ; } # copy to clipboard
wpaste() { xsel -ob 2> /dev/null || cat $s; } # paste from clipboard
vw_key() # machine dependent key
{
    grep ' / ' /etc/fstab | md5sum | sed -e 's/ .*//'
}
