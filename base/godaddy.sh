#!/bin/bash
# +
# Workarounds for syncing without git on godaddy.
# -
godaddy() # use remote host
{
    local godaddy_halt=false
    case "$1" in
    config) # update .ssh/config
        test -f Vagrantfile || echo no vagrant
        test -f Vagrantfile || return
        vagrant ssh-config | sed 1s/default/godaddy.vagrant/ >> ~/.ssh/config
        read -p "check ssh config: "
        vi ~/.ssh/config
        ;;
    local) # run local version of godaddy site
        grep -q godaddy.vagrant ~/.ssh/config || godaddy config
        if ! ssh godaddy.vagrant ; then
            local gt="$VW_DIR/tools/data/godaddy.terminal" 
            if test -f $gt ; then
                open "$gt" 
            else
                godaddy vagrant
            fi
        fi
        ;;
    vagrant) # vagrant up
        (
        sd godaddy > /dev/null
        vagrant up
        ssh godaddy.vagrant
        vagrant halt
        )
        ;;
    vw) # push vw to godaddy
        (
        cd $VW_DIR
        rm -f ~/vw.gz
        git ls | tar --exclude getpass.* -czf ~/vw.gz -T -
        scp ~/vw.gz godaddy:
        rm -f ~/vw.gz
        ssh godaddy "
            mkdir -p .vw
            cd .vw
            tar xf ~/vw.gz
            rm -f ~/vw.gz
            . ./INSTALL
            "
        )
        ;;
    get) # get wordpress from godaddy
        _check || return
        REPLY="$2"
        while ! grep -q 'new|www' <<< "$REPLY" ; do
            read -p 'new or www? '
        done
        ssh godaddy "
            source .bashrc
            sd $REPLY
            wptar ~/junk/godaddy.gz
            "
        scp godaddy:junk/godaddy.gz .
        ssh godaddy "rm ~/junk/godaddy.gz"
        tar xf godaddy.gz
        echo run mk_config, mk_db to update db
        ;;
    archive) # create archive on server
        ssh godaddy ". .bashrc
            sd www
            pso backup archive_$2"
        ;;
    put) # push wordpress to godaddy
        _check || return
        rm -f godaddy.gz
        git ls | tar czf /tmp/godaddy.gz -T -
        scp /tmp/godaddy.gz godaddy:backups
        rm /tmp/godaddy.gz
        ssh godaddy ". .bashrc ; sd www ; pso restore godaddy.gz"
        ;;
    *)
        echo 'usage: godaddy <cmd> where cmd is:'
        (
            cd "$VW_DIR"
            sed -n -e 's/^  \([^\*\(]*\)) #\(.*\)/\1=\2/p' \
                base/godaddy.sh | column -s= -t | tr '=' ' '
        )
        ;;
    esac
}

_godaddy_complete()
{
    COMPREPLY=($(godaddy | sed -e "/^  $2/!d" -e s/..// -e 's/ .*//'))
}
complete -F _godaddy_complete godaddy
