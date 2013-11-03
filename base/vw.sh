#!/bin/bash
# +
# Track and edit configuration files.
# -
vwfiles() # print config files in order sourced
{
    cd "$VW_DIR"
    local VW_FILES=base/*
    local LOCAL_CONFIG=$(_vw_os)
    test -s $LOCAL_CONFIG && VW_FILES="$VW_FILES $LOCAL_CONFIG"
    LOCAL_CONFIG=$(_vw_host)
    test -s $LOCAL_CONFIG && VW_FILES="$VW_FILES $LOCAL_CONFIG"
    echo $VW_FILES
    cd - &> /dev/null
}
_vw_tag()
{
    # make tags for vw scripts
    cd "$VW_DIR"
    local NEW_FILES=tags
    local VW_FILES=$(vwfiles)
    test -s tags && NEW_FILES=$(find $VW_FILES -newer tags)
    test "$NEW_FILES" && tools/shtags.py -t $VW_FILES > tags
    cd - &> /dev/null
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
_vw_reload() { . "$HOME/.bashrc" ; _vw_tag ; }
vwh() { vi "$VW_DIR/$(_vw_host)" ; _vw_reload ; } # vi host config
vwo() { vi "$VW_DIR/$(_vw_os)" ; _vw_reload ; } # vi os config
vwp() { vi -o ~/.bashrc "$VW_DIR/profile" ; _vw_reload ; } # vi vw profile
_vw_md()
{
    # generate markdown
    cd "$VW_DIR"
    tools/shtags.py -m $(vwfiles)
    cd - &> /dev/null
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
_vw_index()
{
    # print index of defintions
    cd "$VW_DIR"
    tools/shtags.py -s $(vwfiles) | sed '
        /\-\-\-/i\

        /^\-\-\-/s/^\-* /* /
    '
    cd - &> /dev/null
}
_vw_dot()
{
    # sync dot files
    pushd $HOME &> /dev/null
    local VW_DOT="$VW_DIR/dot"
    for i in $(ls -A "$VW_DOT")
    do
        cmp -s "$VW_DOT/$i" $i && continue
        local olddir="$HOME" newdir="$VW_DOT"
        test "$newdir/$i" -nt "$olddir/$i" &&
            olddir="$VW_DOT" newdir="$HOME"
        cp -vi "$olddir/$i" "$newdir/$i"
    done
    popd &> /dev/null
}
vwsync() # commit new stuff, get latest
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
    status=$(git remote -v update)
    test "$(git status -uno)" || return
    git push
    _vw_dot
}
vw() # edit the definition of a function, alias or export
{
    test .$1 == . && _vw_index | pr -t -2 -w${COLUMNS:-80} && return
    cd "$VW_DIR"
    local VW_LOC="$(command -v $1 2> /dev/null)" # file location
    _vw_tag
    if grep -q "^$1	" tags ; then
        set $(grep "^$1	" tags)
        vi -t $1
        source $2
        _vw_tag
    elif file -L "$VW_LOC" 2> /dev/null | grep -q text ; then
        vi "$VW_LOC"
    elif test "$VW_LOC" ; then
        echo $1 is $VW_LOC
    elif test "$(ls tools/$1* 2> /dev/null)" ; then
        vi $(ls tools/$1* | head -1)
    else
        echo no match for $1
    fi
    cd - &> /dev/null
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
_vw_complete()
{
    # arg 2 is the guy to search for in tags db
    # returns list of matches as per bash completion
    _vw_tag
    COMPREPLY=($(sed -n "/^$2/s/	.*//p" "$VW_DIR/tags"))
}
complete -o bashdefault -F _vw_complete huh
complete -o bashdefault -F _vw_complete vw
