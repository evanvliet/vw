#!/bin/bash
# +
# A few git shortcuts.
# -
gist()  # root folder, remote url, and current status
{
    local gitroot=$(git rev-parse --show-toplevel)
    test "$gitroot" || return
    echo -n $(git rev-parse --abbrev-ref HEAD) "from "
    echo $(git config remote.origin.url) in $gitroot
    git status -s -uno
}
ci() # git checkin does commit pull and push in one swell foop
{
    local PUSH='' # flag to force push
    test "$1" = "-f" && PUSH='y' && shift
    local REPLY="$*"
    if test "$(git status -s -uno)" ; then
        git diff | cat
        (($(wc -c <<< "$REPLY") > 3)) || read -p 'comment? '
        (($(wc -c <<< "$REPLY") > 3)) && git commit -a -m "$REPLY"
    fi
    git pull
    if test "$REPLY" ; then
        test "$PUSH" || read -p 'push? ' PUSH
        grep -q ^y <<< "$PUSH" && git push
    fi
}
co() # per rcs and old times just git checkout
{
    git checkout $*
}
setconf() # set up a default .gitconfig
{
    local G="$HOME/.gitconfig"
    local V="$VW_DIR/tools/data/gitconfig"
    case $1 in
    di) diff "$G" "$V" ;;
    vi) vi -o "$G" "$V" ;;
    mk)  local EMAIL=$(id -un)@$(hostname)
        local NAME=$(grep ^$(id -un): /etc/passwd | tr , : | cut -d: -f5)
        NAME=${NAME:-$(finger $(id -un) | sed -ne 's/.*Name..//p')}
        sed -e "s/EMAIL/$EMAIL/" -e "s/NAME/$NAME/" "$V" > "$G" ;;
    *)  sed -e 1d -e 's/^ *//' <<< '
            usage: seconf [ di | vi | mk ]
            create / edit  $HOME/.gitconfig
            di - show diff between template
            vi - open with vi along with template
            mk - create from template' ;;
    esac
}
github_create_repository() # as per github create repository quick setup
{
    # presumes the basename of the current folder is the name of the repository
    local GITHUB_DB=$VW_DIR/tools/data/github.id
    local GITHUB_USER=$(cat "$GITHUB_DB" 2> /dev/null)
    test -z "$GITHUB_USER"  && {
        read -p 'github id? ' GITHUB_USER
        echo $GITHUB_USER > "$GITHUB_DB"
    }
    test -z "$GITHUB_USER"  && return
    git remote add origin https://github.com/$GITHUB_USER/$(basename $PWD).git
    git push -u origin master
}
