#!/bin/bash
__='
Conversions, both numbers and file names.
'
dtob() # decimal to binary
{
    echo -n "$1 = "
    echo "$1 2 o p q" | dc
}
dtoh() # decimal to hex
{
    printf '%d = 0x%X\n' $1 $1
}
htob() # hex to binary
{
    local hexval=$(echo $1 | tr "[a-f]" "[A-F]")
    echo -n "0x$hexval = "
    echo "16 i F$hexval 2 o p q" | dc | sed -e 's/1111//' -e 's/..../& /g'
}
htod() # hex to decimal
{
    local hexval=0x$(echo $1 | tr "[a-f]" "[A-F]")
    printf '%s = %d\n' $hexval $hexval
}
tl() # lowercase file names
{
    local i I
    for I in ${*:-*}
    do
        i=$(echo $I | tr '[A-Z]' '[a-z]')
        if test $i != $I && mv $I tmp$$
        then
            mv tmp$$ $i
        fi
    done
}
tu() #  upper case file names
{
    local i I
    for i in ${*:-*}
    do
        I=$(echo $i | tr '[a-z]' '[A-Z]')
        if test $i != $I && mv $i tmp$$
        then
            mv tmp$$ $I
        fi
    done
}
