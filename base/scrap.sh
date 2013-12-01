#!/bin/bash
# +
# Sets up `s` as a scrap file.  For doing stuff like `ls > $s` and
# then editing with `vis`, *etc*.  Another common one is to go `h >
# $s` and then edit your history with `vis`, turning a sequence of
# commands into a shell function.  Then source it with `dots` for
# testing and deployment.  Note dependence on `wcopy` and `wpaste`
# which are os dependent and set up in os-specific config file.
# -
export s=~/.scrap # scrap file
dots() { source $s "$@" ; } # source scrap
ts() { cat $s ; } # type scrap
vis() { vi $s ; } # vi scrap
wcs() { wcopy < $s ; } # copy clipboard to scrap
wps() { wpaste > $s ; } # paste scrap to clipbaord
