#!/bin/bash
# +
# Exported variables and an environmnet pretty printer.
# -
export PS1='\$ ' # prompt
export PS4='(${BASH_SOURCE##*/}''${LINENO}''${FUNCNAME[0]}' # debug info
export PS4='${LINENO} ' # debug info
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: ${PWD/#$HOME/~}\007"' # sets window title
export HISTFILE=$HISTFILE # bash history
export MANPAGER='less -csr' # manpager opts
export PYTHONSTARTUP=~/.pythonrc.py # python startup
export VISUAL=vi # default editor
export CDPATH=.:$VW_DIR:~ # include vw in CDPATH
shopt -s histappend
ep() { # expand paths
    list_parts() {
        env | grep -q ^$1= && env |
            sed -ne /^$1=/s//:/p | # get value
            sed -e "s/.*/$1&:/" | # insert name
            tr ':' '\n'
    }
    list_parts PATH
    list_parts INCLUDE
    list_parts LIB
    list_parts LIBPATH
    list_parts PYTHONPATH
}
