#!/bin/bash
__='
Sets up s as a scrap file. For doing stuff like ls > $s and then
editing with vis, *etc*.
Note dependence on wcopy and wpaste which are  os dependent and
set up in os-specific config file.
'
export s=~/.scrap # scrap file
dots() { . $s "$@" ; } # source scrap
ts() { cat $s ; } # type scrap
vis() { vim $s ; } # vi scrap
wcs() { wcopy < $s ; } # copy clipboard to scrap
wps() { wpaste > $s ; } # paste scrap to clipbaord
