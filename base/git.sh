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
    local REPLY="$@"
    if test "$(git status -s -uno)" ; then
        git diff | head -20
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
    git checkout "$@"
}
clone() # for simplicity
{
    git clone "$@"
}
setconf() # set up a default .gitconfig
{
    local G="$HOME/.gitconfig"
    local V="$VW_DIR/tools/data/gitconfig"
    case $1 in
    di) diff "$G" "$V" ;;
    vi) vi -o "$G" "$V" ;;
    mk) local EMAIL=$(id -un)@$(hostname)
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
    # PWD basename is the name of the repository
    local rep=$(basename $PWD)
	if test -z "$GITHUB_USER" ; then
		echo GITHUB_USER=aaa_id_for_use_on_github >> "$VW_DIR/$(_vw_host)"
		vwh +$
	fi
    test -z "$GITHUB_USER"  && echo no github user && return
    test ! -d .git && echo no .git here to push to github  && return
    read -p "push $rep to $GITHUB_USER? "
    grep -q '^[yY]' <<< $REPLY || return
    git remote add origin https://github.com/$GITHUB_USER/$rep.git
    git push -u origin master
}
