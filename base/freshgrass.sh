#!/bin/bash
# +
# Use vagrant to run the freshgrass vm.
# -
freshgrass() # use remote host
{
    local freshgrass=false
    case "$1" in
    config) # update .ssh/config
        test -f Vagrantfile || echo no vagrant
        test -f Vagrantfile || return
        vagrant ssh-config | sed 1s/default/freshgrass.vagrant/ >> ~/.ssh/config
        read -p "check ssh config: "
        vi ~/.ssh/config
        ;;
    local) # run local version of freshgrass site
        grep -q freshgrass.vagrant ~/.ssh/config || freshgrass config
        local start=$(date +%s)
        if ! ssh freshgrass.vagrant ; then
            (($(date +%s)-start > 2)) && return
            local gt="$VW_DIR/tools/data/Freshgrass.terminal" 
            if test -f $gt ; then
                open "$gt" 
            else
                freshgrass vagrant
            fi
        fi
        ;;
    vagrant) # vagrant up
        (
        sd freshgrass > /dev/null
        vagrant up
        ssh freshgrass.vagrant
        vagrant halt
        )
        ;;
    *)
        echo 'usage: freshgrass <cmd> where cmd is:'
        (
            cd "$VW_DIR"
            sed -n -e 's/^  \([^\*\(]*\)) #\(.*\)/\1=\2/p' \
                base/freshgrass.sh | column -s= -t | tr '=' ' '
        )
        ;;
    esac
}

_freshgrass()
{
    COMPREPLY=($(freshgrass | sed -e "/^  $2/!d" -e s/..// -e 's/ .*//'))
}
complete -F _freshgrass freshgrass
