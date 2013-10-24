#!/bin/bash
<< 'qp'
Definitions and completion routine for vw and huh.
qp
vw() # vi whence
{
    local VW_TMP=/tmp/vw$$
    rm -f $VW_TMP
    case "$1" in
    --usage) # print usage
        echo 'usage: vw [<function>|<variable>|<alias>|<option>]
                --sync  git latest and push changes
                --dot   update $HOME with dot files
                --man   print man page
                --files list config files
                ' | sed -e 's/  */  /'
        ;;
    --HOST) # host config file
        echo host/$(hostname | tr -d '\r ').sh
        ;;
    --OS) # OS config file
        echo os/$(uname | sed -e 's/_.*//').sh
        ;;
    --man) # recap info
        ( cat $VW_DIR/README.md ; vw --md ) | sed -e 's/^##* /* /' -e 's/^*//'
        ;;
    *) # other options need to change dir
        (
        cd "$VW_DIR"
        case "$1" in
        "") # print index of defintions
            tools/shtags.py -s $(vw --files)
            ;;
        --md) # markdown
            tools/shtags.py -m $(vw --files)
            ;;
        --sync) # commit new stuff, get latest
            vw --dot
            git diff --exit-code || (
                read -p 'comment? '
                git commit -a -m "$REPLY"
            )
            git pull
            git push
            vw --dot
            ;;
        --dot) # sync dot files
            cd
            VW_DOT=$(echo $VW_DIR | sed -e "s;$HOME.;;")/dot
            for i in $(ls -A $VW_DOT)
            do
                cmp -s $VW_DOT/$i $i && continue
                olddir=. newdir=$VW_DOT
                test $newdir/$i -nt $olddir/$i && olddir=$VW_DOT newdir=.
                cp -vi $olddir/$i $newdir/$i
            done
            ;;
        --make-tags) # make tags for vw scripts
            MAKE_TAGS=tags
            test -s tags && MAKE_TAGS=$(find $(vw --files) -newer tags)
            test "$MAKE_TAGS" && tools/shtags.py -t $(vw --files) > tags
            ;;
        --files) # return nanes of config files in order
            VW_FILES=base/*
            VW_=$(vw --OS)
            test -s $VW_ && VW_FILES="$VW_FILES $VW_"
            VW_=$(vw --HOST)
            test -s $VW_ && VW_FILES="$VW_FILES $VW_"
            echo $VW_FILES
            ;;
        *) # look up arg and invoke vi or describe
            grep -q '^\-' <<< $1 && vw --usage && return
            vw --make-tags
            VW_LOC=$(command -v $1 2> /dev/null) # file location
            (
            echo cd $VW_DIR
            if grep -q "^$1	" tags
            then set $(grep "^$1	" tags)
                 echo vi -t $1
                 echo . $2
            elif file -L $VW_LOC 2> /dev/null | grep -q text
            then echo vi $VW_LOC > $VW_TMP
            elif test "$(ls tools/$1* 2> /dev/null)"
            then echo vi $(ls tools/$1* | head -1)
            elif test "$VW_LOC"
            then echo echo $1 is $VW_LOC
            else echo echo no match for $1
            fi
            echo 'cd - > /dev/null'
            ) > $VW_TMP
            ;;
        esac
        )
        ;;
    esac
    # this VW_TMP stuff because job control in a subshell has issues
    test -s $VW_TMP && . $VW_TMP
    rm -f $VW_TMP
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
    vw --make-tags
    COMPREPLY=($(sed -n -e "/^$2/s/	.*//p" "$VW_DIR/tags"))
}
complete -F _vw_complete huh
complete -F _vw_complete vw
