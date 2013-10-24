#!/bin/bash
<< 'qp'
Use base machine, *.i.e.*, machine hosting your configuration.  Good on
an isp, ergo the name.
qp
isp() # interact with base machine on isp
{
    << 'qp'
    Start an ssh session, setup and retrieve git repositories, copy
    and paste files. See `isp -h` for usage.
qp
    local ISP_HOST=$(
        cd $VW_DIR; git config remote.origin.url | sed -e s/:.*//)
    local op=$1
    shift
    case $op in
    get)
        scp $ISP_HOST:xfer/$1 .
        ;;
    put)
        scp $* $ISP_HOST:xfer
        ;;
    update)
        ssh $ISP_HOST "cd git_root/$1.git && git fetch"
        ;;
    clone)
        test "$1" && git clone $ISP_HOST:git_root/$1.git && return
        echo 'available repositories:'
        ssh $ISP_HOST 'ls git_root | sed -e "s/^/  /" -e "s/\.git//"'
        ;;
    sh)
        ssh $ISP_HOST $*
        ;;
    git)
        rm -rf .git
        local REPOS=git_root/$(basename $PWD).git
        git init
        git add *
        git ci -m "$REPOS initial commit via isp git"
        ssh $ISP_HOST "mkdir $REPOS; cd $REPOS; git --bare init"
        git remote add origin $ISP_HOST:$REPOS
        git push -u origin master
        ;;
    *)
        echo 'usage: isp [get|sh|put|clone|git] file ...
                get - copy file from xfer folder
                put - copy file to xfer folder
                sh - run sh
                git - create git repository from working directory
                update - update git_root repo from origin, e.g., github
                clone - clone from '$ISP_HOST':~/git_root/' |
            sed -e '2,$s/^ */  /'
        ;;
    esac
}
