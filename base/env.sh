#!/bin/bash
# +
# Exported variables and an environmnet pretty printer.
# -
grep -Eq 'xterm|cygwin' <<< $TERM &&
export PROMPT_COMMAND='echo -ne "\033]0;$(id -un)@$HOSTNAME ${PWD#$HOME/}\007"'
export PS1='\$ ' # prompt
export PS4='${LINENO} ' # debug info
export PS4='+ ${BASH_SOURCE##*/} ${LINENO} ${FUNCNAME[0]} ' # debug info
export MANPAGER='less -csr' # manpager opts
export PYTHONSTARTUP=~/.pythonrc.py # python startup
export VISUAL=vi # default editor
test "$CDPATH" || CDPATH=":$HOME" # default
grep -q "$VW_DIR" <<< "$CDPATH" || CDPATH=$CDPATH:$VW_DIR
grep -q "$VW_DIR" <<< "$PATH" || PATH=$PATH:$VW_DIR/bin
set -o vi
shopt -s histappend
_ep() { env | sed -ne /^$1=/s/$/:/p | tr '=:' '\n' ; }  # split into lines
ep() # expand paths
{
    _ep PATH
    _ep INCLUDE
    _ep LIB
    _ep LIBPATH
    _ep PYTHONPATH
}
