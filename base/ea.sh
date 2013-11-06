#!/bin/bash
# +
# Convenient shortcuts.
# -
alias ..='cd ..; pwd'  # cd ..
alias ...='cd ../..; pwd' # cd ../..
# one liners
chcount () { "$VW_DIR/tools/chcount.py" "$@" | pr -4t ; } # character count
cpo () { cp "$@" "$OLDPWD" ; } # copy to $OLDPWD
findext() { find . -name "*.$1" -print ; } # find by extension
h() { fc -l $* ; } # history
llt() { ls -lgo -t "$@" | head ; } # ls latest
lsc() { ls -bC $* ; } # printable chars
mo() { less -c $* ; } # less -c
r() { fc -s $* ; } # redo
root() { sudo bash ; } # be admin
t() { cat $* ; } # cat
don () # do something a number of times
{
    # +
    # For example, use `don 3 echo` to get 3 blank lines.  Default
    # repetition is `3` and default command is `echo` so acutually,
    # just `don` does the same.
    # -
    local n=3
    ((1$1 > 10)) &> /dev/null && n=$1 && shift
    for i in $(seq $n)
    do
        ${*:-echo}
    done
}
xv () # trace execution of bash script or function
{
    # print separation
    don 5 echo
    # set verbosity and trap restoration
    test -f $1 && bash -xv $@ && return
    trap 'set +xv' ERR EXIT INT RETURN
    set -xv
    $@
}
textbelt() # text phone using textbelt
{
    local TB_INFO=/tmp/textbelt$$
    pn=$(num textbelt | sed -e 's/ .*//')
    test .$pn = . && read -p 'phone number? ' && pn=$REPLY
    curl http://textbelt.com/text -d number=$pn -d message="$*" &> $TB_INFO
    grep -q 'success.:true' $TB_INFO && num -a $pn textbelt
    grep success $TB_INFO
    rm $TB_INFO
}
ea() # echo all
{
    # +
    # Actually echoes just as many file names as will fit on one line.
    # Good for getting a quick idea of the file population of a folder
    # without spamming your screen.  Prints `+nn` to show more files
    # that were not shown.
    # -
    local EATMP=/tmp/ea.$$ MAXCHAR=75
    test "$COLUMNS" && let MAXCHAR=$COLUMNS-5
    trap 'test "$EATMP" && rm -f $EATMP*' RETURN
    test "$@" && ls -d "$@" > $EATMP
    test "$@" || ls > $EATMP
    test -s $EATMP || return
    head -c $MAXCHAR $EATMP > $EATMP.1
    cmp -s $EATMP $EATMP.1 && echo $(cat $EATMP) && return
    sed '$d' $EATMP.1 > $EATMP.2
    echo $(cat $EATMP.2) +$(comm -23 $EATMP $EATMP.2 | wc -l)
}
num() # phone numbers
{
    local NUMS="$VW_DIR/tools/data/num.db"
    case $1 in
    -a) shift # append new info
        grep -v "$*" "$NUMS" > "$NUMS".tmp
        echo $* >> "$NUMS".tmp
        mv "$NUMS".tmp "$NUMS"
        ;;
    -e) vi "$NUMS" # edit db
        ;;
    *)  grep -i "$1" "$NUMS" # search db
        ;;
    esac
}
fm() # fm with history
{
    # +
    # A file management tool for maintaining comments about files. 
    # Lists files with stored comments. Options:
    #   + `-a` prompt for comments for all files, even if there is already a comment
    #   + `-s` prompt for comments for only some of the files, those without a comment
    #
    # Update file comments with the -a or -s option. When prompting
    # for comments, fm recognizes one letter responses as commands to
    # inspect the file, or delete it, or go back to the previous one. 
    # The one letter h response gives usage.  With neither -a nor -s,
    # fm lists existing comments and names of uncommented files.  A
    # trailing list of file names restricts update or report to just
    # those files. If no trailing arguments, it handles all files.
    #
    # Pass HISTFILE and COLUMNS so `fm` can pick up history data and
    # format data for the current screen size.
    # -
    HISTFILE=$HISTFILE COLUMNS=$COLUMNS "$VW_DIR/tools/fm.py" "$@"
}
