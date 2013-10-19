@echo off
rem EP.BAT
rem echoes PATH, Include, Lib
path | sed -e 's/.*=/PATH;/' 2> nul | tr ';' '\n' 2> nul
echo ;Include;%Include% | tr ';' '\n' 2> nul
echo ;Lib;%Lib% | tr ';' '\n' 2> nul
