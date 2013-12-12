#!/bin/bash
# +
# A few git shortcuts.
# -
gist()  # root folder, remote url, and current status
{
    test "$(git root)" || return
    echo $(git root) from $(git config remote.origin.url) [$(git pbr)]
    git status -s -uno
}
ci() # git checkin does commit pull and push in one swell foop
{
    local REPLY=""
    test "$(git status -s -uno)" && {
        git diff
        REPLY="$*"
        test "$REPLY" || read -p 'comment? '
        test "$REPLY" && git commit -a -m "$REPLY"
    }
    git pull
    test "$REPLY" && git push
}
co() # per rcs and old times just git checkout
{
    git checkout $*
}
setconf() # set up a default .gitconfig
{
    local NAME=$(grep ^$(id -un): < /etc/passwd | tr ',' ':' | cut -d: -f5)
    local EMAIL=$(id -un)@$(hostname)
    sed -e "s/NAME/$NAME/
            s/EMAIL/$EMAIL/
            s/^    //" < "$VW_DIR/tools/data/gitconfig" > ~/.gitconfig 
}
