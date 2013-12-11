#!/bin/bash
# +
# A collection of git shortcuts.  Some names influenced by other source
# control systems.  Some encapsulate git opts for convenience.  Others
# collect common seequences.
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
    local EMAIL=$(id -un)@$(hostname)
    local NAME="Eric C. Van Vliet"
    test "$NAME" || NAME=$(awk -F: "/^$(whoami):/ { print \$5 ; }" /etc/passwd | sed s/,.*//)
    test "$NAME" || NAME=$(finger $(whoami) | sed -n 's/.*Name..//p')
    sed -e "s/^    //
            s/NAME/$NAME/
            s/EMAIL/$EMAIL/" > ~/.gitconfig <<< '
    [color]
        ui = auto
        ui = true
    [color "branch"]
        current = yellow reverse
        local = yellow
        remote = white
    [color "diff"]
        meta = yellow bold
        frag = magenta
        old = red bold
        new = green bold
        whitespace = red reverse
    [color "status"]
        added = yellow
        changed = green
        untracked = cyan
    [core]
        whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
        trustctime = false
    [alias]
        br = branch
        di = diff
        f = "!git ls-files | grep -i"
        gr = grep -Ii
        la = "!git config -l | grep alias | cut -c 7-"
        lg = log -p
        ls = ls-files
        pbr = rev-parse --abbrev-ref HEAD
        rmbr = "!f() { git branch -D $1 && git push origin :$1 ; } ; f"
        root = rev-parse --show-toplevel
        st = status
        vdi = difftool -t gdiff
        xlg = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ %ce" --decorate
    [push]
        default = matching
    [user]
        name = NAME
        email = EMAIL
    '
}
