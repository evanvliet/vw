@echo off

set SD_TMP=%TMP%\SD_TMP.cmd
set SD_RC="%HOME%\.sdrc"

if .%1.==.. (
    sort "%HOME%\.sdrc"
    goto :eof
)

type "%SD_RC%" | sed -n -e "/^%1 /s/.*  //p" | cygpath -wf - | sed -e "s/^/CD /" > %SD_TMP%
call %SD_TMP%
grep -q CD %SD_TMP%
if errorlevel 1 type "%SD_RC%" | sed -n -e "/^%1/s/ .*//p"
rem del %SD_TMP%
