#!/bin/bash
# +
# Track, sync and edit configuration files.
# -
vw() # edit the definition of a function, alias or export
{
    test -z "$1" && _vw_index && return
    test ! -t 1 && echo output is not a terminal && return
    pushd "$VW_DIR" > /dev/null
    _vw_tag
    local LOC="$(command -v $1 2> /dev/null)"
    if grep -q "^$1	" tags ; then
        vi -t $1
        source "$VW_DIR/profile"
    elif file -L "$LOC" 2> /dev/null | grep -q text ; then
        vi "$LOC"
    else
        echo $1 is ${LOC:-not found}
    fi
    popd > /dev/null
}
vwh() # vi host config
{
    vi "$VW_DIR/$(_vw_host)"
    source "$VW_DIR/profile"
}
vwo() # vi os config
{
    vi "$VW_DIR/$(_vw_osys)"
    source "$VW_DIR/profile"
}
vwp() # vi vw profile
{
    vi -o $HOME/.bashrc "$VW_DIR/profile"
    source "$VW_DIR/profile"
}
vwman() # recap info
{
    _vw_md > "$VW_DIR"/INDEX.md
    sed -e '/^##* /i\

            s/^##* /# /
            s/^*//' \
        "$VW_DIR"/README.md \
        "$VW_DIR"/INDEX.md | $MANPAGER
}
_vw_dot() # link vw dot files to home directory
{
    pushd "$VW_DIR/dot" > /dev/null
    cd
    for i in $(ls -A "$OLDPWD");
    do
        if test ! $i -ef "$OLDPWD/$i"  ; then
            cmp -s $i "$OLDPWD/$i" || mv -v $i $i.bak
            ln -f "$OLDPWD/$i" .
        fi
    done
    popd > /dev/null;
}
vwsync() # commit new stuff and get latest
{
    _vw_dot
    # prompt for comment if committing changes
    pushd "$VW_DIR" > /dev/null
    local REPLY="$*"
    if test "$(git status -s -uno)" ; then
        git diff | cat
        (($(wc -c <<< "$REPLY") > 3)) || read -p 'comment? '
        (($(wc -c <<< "$REPLY") > 3)) && git commit -a -m "$REPLY"
    fi
    # sync up
    git pull 
    if (($(wc -c <<< "$REPLY") > 3)) ; then
        git push
    fi
    _vw_dot
    source ./profile
    popd > /dev/null
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
    cd "$VW_DIR"
    local FILES=base/*.sh
    test -s $(_vw_osys) && FILES="$FILES $(_vw_osys)"
    test -s $(_vw_host) && FILES="$FILES $(_vw_host)"
    echo $FILES
    cd - > /dev/null
}
_vw_tag()
{
    # tags for vw scripts
    local FILES=tags
    test -s tags && FILES=$(find $(vwfiles) -newer tags)
    test "$FILES" && tools/shtags.py -t ~/.bashrc $(vwfiles) > tags
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
_vw_md()
{
    # generate markdown
    pushd "$VW_DIR" > /dev/null
    tools/shtags.py -m $(vwfiles)
    popd > /dev/null
}
_vw_index()
{
    # print index of defintions
    pushd "$VW_DIR" > /dev/null
    local PAGER="pr -t -2 -w${COLUMNS:-80}"
    test -t 1 || PAGER=cat
    tools/shtags.py -s $(vwfiles) | sed '
        /\-\-\-/i\

        /^\-\-\-/s/^\-* /* /
    ' | $PAGER
    popd > /dev/null
}
_vw_complete()
{
    # arg 2 is the guy to search for in tags db
    # return list of matches as per bash completion
    pushd "$VW_DIR" > /dev/null
    _vw_tag
    COMPREPLY=($(sed -n "/^$2/s/	.*//p" tags))
    popd > /dev/null
}
complete -o bashdefault -F _vw_complete huh
complete -o bashdefault -F _vw_complete vw
