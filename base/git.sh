#!/bin/bash
# +
# A few git shortcuts.
# -
gist()  # root folder, remote url, and current status
{
    test "$(git root)" || return
    echo $(git pbr) from $(git config remote.origin.url) in $(git root)
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
    *)  local EMAIL=$(id -un)@$(hostname)
        local NAME=$(grep ^$(id -un): /etc/passwd | tr , : | cut -d: -f5)
        NAME=${NAME:-$(finger eric | sed -ne 's/.*Name..//p')}
        sed -e "s/EMAIL/$EMAIL/" -e "s/NAME/$NAME/" "$V" > "$G" ;;
    esac
}
github_create_repository() # as per github create repository quick setup
{
    local GITHUB_USER=evanvliet
    git remote add origin https://github.com/$GITHUB_USER/$(basename $PWD).git
    git push -u origin master
}
