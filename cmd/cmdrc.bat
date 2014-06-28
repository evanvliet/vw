@echo off

rem add cygwin and some shortcuts
rem
rem for use from shorcut with a target of:
rem      %windir%\system32\cmd.exe /k vw\cmd\cmdrc.bat
rem and a staring directory of %USERPROFILE% or other
rem directory containing the vw package

if ..==.%HOMEDRIVE%. (
    SET HOMEDRIVE=%SystemDrive%
)
if ..==.%HOME%. (
    SET HOME=%USERPROFILE%
)

rem // need goto because parentheses in path discombobulates scripts
if ..==.%CYGWIN_PATH%. set CYGWIN_PATH=%HOMEDRIVE%\CYGWIN\BIN
path | %WINDIR%\System32\find.exe /i "cygwin" > nul
if not errorlevel 1 goto next_aa
if exist %CYGWIN_PATH%\ps.exe PATH %PATH%;%CYGWIN_PATH%
:next_aa

PATH | %WINDIR%\System32\find.exe /i "%~dp0" > nul
if not errorlevel 1 goto next_ab
PATH %PATH%;%~dp0
:next_ab

DOSKEY MO=LESS -c $*
DOSKEY EA=PRINTF "%%s " *
DOSKEY ES=PRINTF "%%s " $*
DOSKEY PBRUSH=MSPAINT $*
DOSKEY WORDPAD="%ProgramFiles%\Windows NT\Accessories\Wordpad"
DOSKEY LL=LS -lgo $*
DOSKEY VSU=NOTEPAD %~dp0\cmdrc.bat
DOSKEY VSL=NOTEPAD "%~dp0local_%COMPUTERNAME%.bat"
DOSKEY VDIR=EXPLORER .
DOSKEY ANT=C:\ANT\BIN\ANT $*
DOSKEY NOTE=NOTEPAD $*
DOSKEY vihosts=notepad %WINDIR%\System32\drivers\etc\hosts
DOSKEY SPHOME=PUSHD "%HOME%"
DOSKEY HOME=PUSHD %HOME%
DOSKEY VS9=if not defined DevEnvDir call "%VS90COMNTOOLS%"\vsvars32.bat
DOSKEY VS10=if not defined DevEnvDir call "%VS100COMNTOOLS%"\vsvars32.bat
DOSKEY VI=VIM $*
DOSKEY FM=bash -c "python $(cygpath '%~dp0..\tools\fm.py') $*"
DOSKEY ..=CD ..
DOSKEY ...=CD ..\..

TITLE %COMPUTERNAME%

if not defined SESSIONNAME (
    PROMPT $P$S$_$G
    COLOR F1
    CD %HOME%
) else (
    PROMPT $P$S$+$_$G
)

rem // local environment
set LOCALX=%~dp0\local_%COMPUTERNAME%.bat
if exist "%LOCALX%" (
    call "%LOCALX%" 
) else (
    echo rem %LOCALX% > "%LOCALX%"
    start notepad %LOCALX%
)

