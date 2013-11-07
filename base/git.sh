#!/bin/bash
# +
# A collection of git shortcuts.  Some names influenced by other source
# control systems.  Some encapsulate git opts for convenience.  Others
# collect common seequences.
# -
gist()  # root folder, remote url, and current status
{
    gitroot="$(git rev-parse --show-toplevel 2> /dev/null)"
    test "$gitroot" || return
    echo $gitroot $(gitbr) from $(git config remote.origin.url)
    git status -s -uno
}
gitbr() # show branch name or delete with -d
{
    git rev-parse --is-inside-work-tree &> /dev/null || return
    test ! $1. = -d. && git rev-parse --abbrev-ref HEAD && return
    git branch | grep -q $2 && git branch -D $2
    test $2 = master || git push origin :$2
}
ci() # git checkin does commit pull and push in one swell foop
{
    git commit -a -m "${*:-ci from $(id -un)@$(hostname)}"
    git pull
    git push
}
co() # per rcs and old times just git checkout
{
    git checkout $*
}
lastdiff() # last diff for a file
{
    git diff $(git log -2 $1 | sed -n /commit./s///p) $1
}
setconf() # set up a default .gitconfig
{
    local EMAIL=$(id -un)@$(hostname)
    local NAME=$(awk -F: "/^$(whoami):/ { print \$5 ; }" /etc/passwd | sed s/,.*//)
    test "$NAME" || NAME=$(finger $(whoami) | sed -n 's/.*Name..//p')
    sed -e "s/^ *\[/[/
            s/^  */  /
            s/FULL_NAME/$NAME/
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
        st = status
        ci = commit -a
        ad = add
        ls = ls-files
        br = branch
        co = checkout
        lg = log -p
        di = diff
        vdi = difftool -t meld
    [push]
        default = matching
    [user]
        name = FULL_NAME
        email = EMAIL
    '
}
