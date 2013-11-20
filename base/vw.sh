#!/bin/bash
# +
# Track, sync and edit configuration files.
# -
vw() # edit the definition of a function, alias or export
{
    test "$1" || { _vw_index ; return ; }
    test -t 1 || { echo output is not a terminal ; return ; }
    pushd "$VW_DIR" &> /dev/null
    _vw_tag
    if grep -q "^$1	" tags ; then
        vi -t $1
        _vw_reload
    else
        local LOC="$(command -v $1 2> /dev/null)" # general command
        test "$LOC" || LOC=$(ls tools/$1* 2> /dev/null | sed 1q) # vw tool
        if file -L "$LOC" 2> /dev/null | grep -q text ; then
            vi "$LOC"
        elif test "$LOC" ; then
            echo $1 is $LOC
        else
            echo no match for $1
        fi
    fi
    popd > /dev/null
}
vwh() # vi host config
{
    vi "$VW_DIR/$(_vw_host)"
    _vw_reload
}
vwo() # vi os config
{
    vi "$VW_DIR/$(_vw_osys)"
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
    if test "$(git status -s -uno)" ; then
        git diff
        git status -s
        read -p 'comment? '
        test "$REPLY" || return
        git commit -a -m "$REPLY"
    fi
    git pull
    git push
    _vw_reload
    _vw_dot
}
huh() # melange of type typeset alias info
{
    local HUH=$(type $1 2> /dev/null)
    case "$HUH" in
    *function*)   typeset -f $1 ;;
    "" | *found)  echo $1 not found ;;
    *aliased?to*) alias $1 ;;
    *)            printf "%s\n" "$HUH" ;;
    esac;
}
vwfiles() # print config files in order sourced
{
    # really for internal use but needed in vw profile
    pushd "$VW_DIR" &> /dev/null
    local FILES=base/*.sh
    test -s $(_vw_osys) && FILES="$FILES $(_vw_osys)"
    test -s $(_vw_host) && FILES="$FILES $(_vw_host)"
    echo $FILES
    popd &> /dev/null
}
_vw_tag()
{
    # tags for vw scripts
    local FILES=tags
    test -s tags && FILES=$(find $(vwfiles) -newer tags)
    test "$FILES" && tools/shtags.py -t $(vwfiles) > tags
}
_vw_host()
{
    # host config file
    echo host/$(hostname | tr -d '\r ').sh
}
_vw_osys()
{
    # OS config file
    echo os/$(uname | sed -e 's/_.*//').sh
}
_vw_reload()
{
    # load source files and build tags
    pushd "$VW_DIR" &> /dev/null
    _vw_tag
    popd &> /dev/null
    . "$HOME/.bashrc"
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
    pushd "$HOME" &> /dev/null
    trap 'popd &> /dev/null' RETURN EXIT INT
    for i in $(ls -A "$VW_DIR/dot")
    do
        local old=$i new="$VW_DIR/dot/$i"
        cmp -s "$new" $i && continue
        test "$old" -nt "$new" && old="$VW_DIR/dot/$i" new=$i
        cp -vi "$new" "$old"
    done
}
_vw_complete()
{
    # arg 2 is the guy to search for in tags db
    # return list of matches as per bash completion
    pushd "$VW_DIR" &> /dev/null
    _vw_tag
    COMPREPLY=($(sed -n "/^$2/s/	.*//p" tags))
    popd &> /dev/null
}
complete -o bashdefault -F _vw_complete huh
complete -o bashdefault -F _vw_complete vw
