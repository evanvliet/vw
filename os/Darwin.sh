#!/bin/bash
# +
# For mac.  Added a ssh-copy-id goody.
# -
export LC_CTYPE=C # sed-re-error-illegal-byte-sequence-on-mac-os-x
export LANG=C # sed-re-error-illegal-byte-sequence-on-mac-os-x
browse() { open -a /Applications/Google\ Chrome.app "$@" ; } # web
gdiff() { opendiff $* ; } # gui diff
gdir() { open . ; } # gui dir
gedit() { open -a TextEdit $1 ; } # gui editor
wcopy() { pbcopy ; } # copy to clipboard
wpaste() { pbpaste ; } # paste from clipboard
hostid() # missing on mac
{
    ( sysctl kern.uuid ; sysctl kern.bootsignature ) 2>&1 | md5
}
ssh-copy-id() # for mac
{
    cat ~/.ssh/id_rsa.pub | ssh $1 '
        mkdir -p .ssh;
        chmod go-rwx .ssh;
        cat - >> .ssh/authorized_keys'
}
python-vi-mode() # mac python uses editrc vs readline
{
    local bind="bind -v" rc=~/.editrc
    grep -q "$bind" $rc 2> /dev/null || echo $bind >> $rc
}
alias ll='ls -alF'
