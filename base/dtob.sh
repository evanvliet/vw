#!/bin/bash
<< 'qp'
Conversions, both numbers and file names. Dates from looking
at a datascope and dealing with file names on Eunice.
qp
_tu() { echo $1 | tr '[a-z]' '[A-Z]' ; }
_tl() { echo $1 | tr '[A-Z]' '[a-z]' ; }
dtoh() # decimal to hex
{
    printf '%d = 0x%X\n' $1 $1
}
htod() # hex to decimal
{
    printf '0x%X = %d\n' $((0x$1)) $((0x$1))
}
htob() # hex to binary
{
    local val=$(_tu $1)
    echo 0x$val = $(echo "16 i 1$val 2 o p q" | \
        dc | sed -e s/1// -e 's/..../& /g')
}
dtob() # decimal to binary
{
    local i=$(dtoh $1)
    i=$(htob ${i#*x})
    echo $1 = ${i#*= }
}
recase() # upper case file names or use -lower to lower case
{
    local tmp=tmp$$ casing=upper
    test "$1" = -lower && shift && casing=lower
    for i in ${@:-*}
    do
        local I=$(_tu "$i")
        test $casing = lower && I=$(_tl "$i")
        test "$i" = "$I" && continue
        mv "$i" "$tmp"
        mv "$tmp" "$I"
    done
}
