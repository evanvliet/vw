#!/bin/bash
# +
# For linux.
# -
browse() # web
{
    local url=${1:-google.com}
    test "${url##http*}" && url="http://$url"
    ( nohup xdg-open $url & ) &> /dev/null
}
gdiff() { meld $* 2> /dev/null . ; } # gui diff
gdir() { nautilus 2> /dev/null . ; } # gui files
gedit() { /usr/bin/gedit -b $1 ; } # gui editor
wcopy() { xsel -ib 2> /dev/null || cat - > $s.clip ; } # copy to clipboard
wpaste() { xsel -ob 2> /dev/null || cat $s.clip; } # paste from clipboard
sys_update() { time sudo "apt-get update && apt-get dist-upgrade" ; }
