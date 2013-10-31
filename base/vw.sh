#!/bin/bash
# +
# Track and edit configuration files.
# -
vw() # edit the definition of a function, alias or export 
{
    case "$1" in
    "") # print index of defintions
        cd $VW_DIR
        tools/shtags.py -s $(vw --files) | sed '
            /\-\-\-/i\

            /^\-\-\-/s/^\-* /* /
        '
        cd - &> /dev/null
        ;;
    --HOST) # host config file
        echo host/$(hostname | tr -d '\r ').sh
        ;;
    --OS) # OS config file
        echo os/$(uname | sed -e 's/_.*//').sh
        ;;
    --dot) # sync dot files
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
        ;;
    --files) # return nanes of config files in order
        cd $VW_DIR
        local VW_FILES=base/*
        local VW_=$(vw --OS)
        test -s $VW_ && VW_FILES="$VW_FILES $VW_"
        VW_=$(vw --HOST)
        test -s $VW_ && VW_FILES="$VW_FILES $VW_"
        echo $VW_FILES
        cd - &> /dev/null
        ;;
    --tag) # make tags for vw scripts
        cd $VW_DIR
        local MAKE_TAGS=tags
        test -s tags && MAKE_TAGS=$(find $(vw --files) -newer tags)
        test "$MAKE_TAGS" && tools/shtags.py -t $(vw --files) > tags
        cd - &> /dev/null
        ;;
    --man) # recap info
        vw --md > $VW_DIR/INDEX.md
        sed -e '/^##* /i\

                s/sh](.*/sh]/
                s/^##* /# /
                s/^*//' \
            $VW_DIR/README.md \
            $VW_DIR/INDEX.md | $MANPAGER
    ;;
    --md) # markdown
        cd $VW_DIR
        tools/shtags.py -m $(vw --files)
        cd - &> /dev/null
        ;;
    --sync) # commit new stuff, get latest
        vw --dot
        pushd $VW_DIR &> /dev/null
        git diff --exit-code || (
            read -p 'comment? '
            test "$REPLY" && git commit -a -m "$REPLY"
            )
        git pull
        git push
        vw --dot
        popd &> /dev/null
        ;;
    -*) # print usage
        sed 's/  */  /' <<< 'usage: vw [<function>|<export>|<option>]
            --sync  git latest and push changes
            --man   print man page'
        ;;
	*) # look up arg and invoke vi or describe
        cd $VW_DIR
        local VW_LOC="$(command -v $1 2> /dev/null)" # file location
        vw --tag
        if grep -q "^$1	" tags ; then
            set $(grep "^$1	" tags)
            vi -t $1
            source $2
            vw --tag
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
        ;;
    esac
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

_vw_complete() { vw --tag ; COMPREPLY=($(sed -n "/^$2/s/	.*//p" "$VW_DIR/tags")) ; }
complete -F _vw_complete huh
complete -F _vw_complete vw

vw --tag # udpate tags at login
