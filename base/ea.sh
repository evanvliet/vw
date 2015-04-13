#!/bin/bash
# +
# Convenient shortcuts.
# -
alias ..='cd ..; pwd'  # cd ..
alias ...='cd ../..; pwd' # cd ../..
alias cdvw='cd "$VW_DIR"; pwd' # cd vw dir
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
vimrc() { vi ~/.vimrc ; } # edit .vimrc
don () # do something a number of times
{
    # +
    # For example, use `don 3 echo` to get 3 blank lines.  Default
    # repetition is `3` and default command is `echo` so acutually,
    # just `don` does the same.
    # -
    local n=3
    ((1$1 > 10)) &> /dev/null && n=$1 && shift
    while (($n > 0))
    do
        ${*:-echo}
        let n=n-1
    done
}
xv () # trace execution of bash script or function
{
    # print separation
    don 5
    # set verbosity and trap restoration
    test -f $1 && bash -xv "$@" && return
    set -xv
    "$@"
    set +xv
}
textbelt() # text phone using textbelt
{
    local TB_=/tmp/textbelt$$
    local REPLY=$(num textbelt | sed -e 's/ .*//')
    test -z "$REPLY" && read -p 'phone number? '
    curl http://textbelt.com/text -d number=$REPLY -d message="$*" &> $TB_
    grep -q 'success.:true' $TB_ && num -a $REPLY textbelt
    grep success $TB_
    rm $TB_
}
ea() # echo all
{
    # +
    # Actually echoes just as many file names as will fit on one line.
    # Good for getting a quick idea of the file population of a folder
    # without spamming your screen.  Prints `+nn` to show number of
    # files that were not listed.
    # -
    local EATMP=/tmp/ea.$$ MAXCHAR=${COLUMNS:-80}
    let MAXCHAR=$MAXCHAR-6
    test "$*" || \ls -b > $EATMP.1
    test "$*" && \ls -bd "$@" > $EATMP.1 2> /dev/null
    test -s $EATMP.1 && (
        head -c $MAXCHAR $EATMP.1 > $EATMP
        if ! cmp -s $EATMP $EATMP.1 ; then
            # remove last (probably incomplete) file name
            sed '$d' $EATMP > $EATMP.2
            # + number of unlisted files
            echo $(cat $EATMP.2) +$(comm -23 $EATMP.[12] | wc -l) > $EATMP
        fi
        echo $(cat $EATMP)
        )
    rm -f $EATMP*
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
fm() # fm with history and sceen width
{
    history -a
    HISTFILE=$HISTFILE COLUMNS=$COLUMNS fm.py "$@"
}
