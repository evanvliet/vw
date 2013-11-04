#!/bin/bash
# +
# Track, sync and edit configuration files.
# -
vw() # edit the definition of a function, alias or export
{
    test "$1" || { _vw_index ; return ; }
    test -t 1 || { echo output is not a terminal ; return ; }
    pushd "$VW_DIR" &> /dev/null
    trap 'popd &> /dev/null' RETURN EXIT INT
    _vw_tag
    grep -q "^$1	" tags && vi -t $1 && _vw_reload && return
    local LOC="$(command -v $1 2> /dev/null)" # general command
    test "$LOC" || LOC=$(ls tools/$1* 2> /dev/null | sed 1q) # vw tool
    file -L "$LOC" 2> /dev/null | grep -q text && vi "$LOC" && return
    test "$LOC" && echo $1 is $LOC && return
    echo no match for $1
}
vwh() # vi host config
{
    vi "$VW_DIR/$(_vw_host)" 
    _vw_reload 
}
vwo() # vi os config
{
    vi "$VW_DIR/$(_vw_os)" 
    _vw_reload 
}
vwp() # vi vw profile
{
    vi -o ~/.bashrc "$VW_DIR/profile" 
    _vw_reload 
}
vwman() # recap info
{
    _vw_md > "$VW_DIR"/INDEX.md
    sed -e '/^##* /i\

            s/sh](.*/sh]/
            s/^##* /# /
            s/^*//' \
        "$VW_DIR"/README.md \
        "$VW_DIR"/INDEX.md | $MANPAGER
}
vwsync() # commit new stuff and get latest
{
    _vw_dot
    pushd "$VW_DIR" &> /dev/null
    trap 'popd &> /dev/null' RETURN INT EXIT
    if test "$(git status -s)" ; then
        git diff
        git status -s
        read -p 'comment? '
        test "$REPLY" || return
        git commit -a -m "$REPLY"
    fi
    git pull
    git push
    _vw_dot
    _vw_reload
}
huh() # melange of type typeset alias info
{
    local HUH=$(type $1 2> /dev/null)
    case "$HUH" in
    "" | *found)  echo $1 not found ;;
    *function*)   typeset -f $1 ;;
    *aliased?to*) alias $1 ;;
    *)            printf "%s\n" "$HUH" ;;
    esac;
}
vwfiles() # print config files in order sourced
{
    # really for internal use but needed in vw profile
    pushd "$VW_DIR" &> /dev/null
    local FILES=base/*
    local LOCAL_CONFIG=$(_vw_os)
    test -s $LOCAL_CONFIG && FILES="$FILES $LOCAL_CONFIG"
    LOCAL_CONFIG=$(_vw_host)
    test -s $LOCAL_CONFIG && FILES="$FILES $LOCAL_CONFIG"
    echo $FILES
    popd &> /dev/null
}
_vw_tag()
{
    # make tags for vw scripts
    local NEW_FILES=tags
    local FILES=$(vwfiles)
    test -s tags && NEW_FILES=$(find $FILES -newer tags)
    test "$NEW_FILES" && tools/shtags.py -t $FILES > tags
}
_vw_host()
{
    # return host config file
    echo host/$(hostname | tr -d '\r ').sh
}
_vw_os()
{
    # return OS config file
    echo os/$(uname | sed -e 's/_.*//').sh
}
_vw_reload()
{
    pushd "$VW_DIR" &> /dev/null
    . "$HOME/.bashrc"
    _vw_tag
    popd &> /dev/null
}
_vw_md()
{
    # generate markdown
    pushd "$VW_DIR" &> /dev/null
    tools/shtags.py -m $(vwfiles)
    popd &> /dev/null
}
_vw_index()
{
    # print index of defintions
    pushd "$VW_DIR" &> /dev/null
    local PAGER="pr -t -2 -w${COLUMNS:-80}"
    test -t 1 || PAGER=cat
    tools/shtags.py -s $(vwfiles) | sed '
        /\-\-\-/i\

        /^\-\-\-/s/^\-* /* /
    ' | $PAGER
    popd &> /dev/null
}
_vw_dot()
{
    # sync dot files
    pushd $HOME &> /dev/null
    local DOT="$VW_DIR/dot"
    for i in $(ls -A "$DOT")
    do
        cmp -s "$DOT/$i" $i && continue
        local olddir="$HOME" newdir="$DOT"
        test "$newdir/$i" -nt "$olddir/$i" &&
            olddir="$DOT" newdir="$HOME"
        cp -vi "$olddir/$i" "$newdir/$i"
    done
    popd &> /dev/null
}
_vw_complete()
{
    # arg 2 is the guy to search for in tags db
    # returns list of matches as per bash completion
    pushd "$VW_DIR" &> /dev/null
    _vw_tag
    COMPREPLY=($(sed -n "/^$2/s/	.*//p" tags))
    popd &> /dev/null
}
complete -o bashdefault -F _vw_complete huh
complete -o bashdefault -F _vw_complete vw
