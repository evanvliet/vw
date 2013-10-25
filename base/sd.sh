#!/bin/bash
<< 'qp'
Nicknames for directory navigation.
qp
sd() # set directory via nicknames
{
    << 'qp'
    Use `sd nick` to cd to folder by nickname `nick`. If `nick`
    unknown, save it for the current directory. Without arg, `sd`
    lists known nicknames.  Options:
      + `-e` edit db, using vi
      + `-l` tail db, list last added nicknames
      + `-v` expand nick, for use in other scripts
qp
    local SDTMP=$(sed -n -e "/^$2 /s/.*  //p" ~/.sdrc)
    test -f ~/.sdrc || touch ~/.sdrc
    case "$1" in
    "") sort ~/.sdrc
        ;;
    -e) vi ~/.sdrc
        ;;
    -l) tail ~/.sdrc
        ;;
    -v) test "$SD_TMP" && echo $SD_TMP
        ;;
    -h) sed 's/^  */   /' <<< 'sd [<nick> | -e | -l | -v]
            -e edit db
            -l tail db
            -v expand nick'
        ;;
    *)  test -d "$SD_TMP" && cd "$SD_TMP" && pwd && return
        # add new nickname
        read -p "add $1 as a shortcut to $PWD? "
        grep -q y <<< $REPLY || return
        # replace existing versions with current one
        grep -v "^$1 " ~/.sdrc > ~/.sd_tmp
        mv ~/.sd_tmp ~/.sdrc
        printf "%-9s  %s\n" $1 "$PWD" | tee -a ~/.sdrc
        ;;
    esac
}
_sd_complete() { COMPREPLY=($(sed -n -e "/^$2/s/ .*//p" ~/.sdrc)) ; }
complete -F _sd_complete sd
