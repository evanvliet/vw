#!/bin/bash
# +
# Use base machine, *.i.e.*, machine hosting your configuration.  Good
# to have on an isp, ergo the name.  The subcommand covers copying files,
# running a shell, using git to create, clone repositiories.
# -
isp() # interact with base machine
{
    # +
    # Subcommands:
    #   + `get` copy file from xfer folder
    #   + `put` copy file to xfer folder
    #   + `shell` run ssh
    #   + `clone` clone from '$ISP_HOST':~/git_root/'
    #   + `create` create git repository from working directory
    # -
    local ISP_HOST=$(
        cd "$VW_DIR"; git config remote.origin.url | sed -e s/:.*//)
    local op=$1
    shift
    case $op in
    get) # copy file from xfer folder
        scp $ISP_HOST:xfer/$1 . ||
        isp shell 'ls -lgoth xfer | sed -n 2,12s/.............//p'
        ;;
    put) # copy file to xfer folder
        isp shell mkdir -p xfer
        scp $* $ISP_HOST:xfer
        ;;
    ssh|shell) # run ssh
        ssh $ISP_HOST $*
        ;;
    clone) # clone from collection of repositories in git_root
        test "$1" && git clone $ISP_HOST:git_root/$1.git && return
        echo 'available repositories:'
        ssh $ISP_HOST 'ls git_root | sed -e "s/^/  /" -e "s/\.git//"'
        ;;
    create) # create git repository from working directory
        rm -rf .git
        local REPOS=git_root/$(basename $PWD).git
        git init
        git add *
        git commit -a -m "$REPOS initial commit via isp git"
        ssh $ISP_HOST "mkdir $REPOS; cd $REPOS; git --bare init"
        git remote add origin $ISP_HOST:$REPOS
        git push -u origin master
        ;;
    *) # show help text
        echo 'isp [ get | put | shell | clone | create ] ...'
        sed -n -e 's/^  \([^\*\(]*\)) #\(.*\)/\1=\2/p' \
            "$VW_DIR/base/isp.sh" | column -s= -t | tr '=' ' '
        ;;
    esac
}
