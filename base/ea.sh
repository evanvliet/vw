#!/bin/bash
# +
# Convenient shortcuts.
# -
alias ..='cd ..; pwd'  # cd ..
alias ...='cd ../..; pwd' # cd ../..
# one liners
chcount () { "$VW_DIR/tools/chcount.py" "$@" | pr -4t ; } # character count
cpo () { cp $* "$OLDPWD" ; } # copy to $OLDPWD
findext() { find . -name "*.$1" -print ; } # find by extension
fm() { history -a; "$VW_DIR/tools/fm.py" "$@" ; } # fm with history
h() { fc -l $* ; } # history
llt() { ls -lgo -t "$@" | head ; } # ls latest
lsc() { ls -bC $* ; } # printable chars
mo() { less -c $* ; } # less -c
r() { fc -s $* ; } # redo
root() { sudo bash ; } # be admin
t() { cat $* ; } # cat
# vw related
vwh() { vi "$VW_DIR/$(vw --HOST)" ; . "$HOME/.bashrc" ; } # vi host config
vwo() { vi "$VW_DIR/$(vw --OS)" ; . "$HOME/.bashrc" ; } # vi os config
vwp() { vi -o ~/.bashrc "$VW_DIR/profile" ; . "$HOME/.bashrc" ; } # vi vw profile
vws() { vi -o  $(ls $VW_DIR/base/$1* | head -3) ; . "$HOME/.bashrc" ; } # vi base config
don () # do something a number of times
{ 
    # +
    # For example, use `don 3 echo` to get 3 blank lines.
    # -
    local n=3
    ((1$1 > 10)) &> /dev/null && n=$1 && shift
    for i in $(seq $n)
    do
        $*
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
    local EACOLS EATMP=/tmp/ea.$$
    trap 'test "$EATMP" && rm -f $EATMP*' RETURN
    let EACOLS=$COLUMNS-6
    ls -d ${@:-*} > $EATMP
    head -c $EACOLS $EATMP > $EATMP.1
    cmp -s $EATMP $EATMP.1 && echo $(cat $EATMP) && return
    sed -e '$d' $EATMP.1 > $EATMP.2
    echo $(cat $EATMP.2) +$(comm -23 $EATMP $EATMP.2 | wc -l)
}
num() # phone numbers
{
    NUM_DB="$VW_DIR/tools/data/num.db"
    case $1 in
    -a) shift # append new info
        grep -v "$*" $NUM_DB >> $NUM_DB.tmp
        echo $* >> $NUM_DB.tmp && mv $NUM_DB.tmp $NUM_DB
        ;;
    -e) vi $NUM_DB # edit db
        ;;
    *)  grep -i "$1" $NUM_DB # search db
        ;;
    esac
}
