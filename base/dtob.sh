#!/bin/bash
# +
# Conversions, both numbers and file names. Dates from looking
# at a datascope and dealing with file names on Eunice.
# -
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
    local hex=$(tr [:lower:] [:upper:] <<< $1)
    local bin=$(dc <<< "16 i 1$hex 2 o p")
    echo 0x$hex = $(sed -e 's/..../& /g' <<< ${bin#1})
}
dtob() # decimal to binary
{
    local hex=$(dtoh $1)
    local bin=$(htob ${hex#*x})
    echo $1 = ${bin#*= }
}
recase() # upper case file names or use -lower to lower case
{
    local tmp=tmp$$ casing=upper
    test "$1" = -lower && shift && casing=lower
    for i in "${@:-*}"
    do
        test $casing = upper && local I=$(tr [:lower:] [:upper:] <<< "$i")
        test $casing = lower && local I=$(tr [:upper:] [:lower:] <<< "$i")
        test "$i" = "$I" && continue
        mv "$i" "$tmp"
        mv "$tmp" "$I"
    done
}
