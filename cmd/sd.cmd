@echo off

set SD_TMP=%TMP%\SD_TMP.cmd
set SD_RC="%HOME%\.sdrc"
rem if not exist "%SD_RC%" set SD_RC=c:\cygwin\home\eric\.sdrc
set SD_RC=c:\cygwin\home\eric\.sdrc

if .%1.==.. (
    sort "%SD_RC%"
    goto :eof
)

sed -n -e "/^%1 /s/.*  //p" < "%SD_RC%" | cygpath -wf - | sed -e "s/^/CD /" > %SD_TMP%
call %SD_TMP%
grep -q CD %SD_TMP%
if errorlevel 1 type "%SD_RC%" | sed -n -e "/^%1/s/ .*//p"
rem del %SD_TMP%
