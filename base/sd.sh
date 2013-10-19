#!/bin/bash
__='
Nicknames for directory navigation.
'
sd() # set directory via nicknames
{
    __='
    Use `sd nick` to cd to folder by nickname `nick`. If `nick`
    unknown, save it for the current directory. Without arg, `sd`
    lists known nicknames.  Options:
      + `-e` edit db, using vi
      + `-l` tail db, list last added nicknames
      + `-v` expand nick, for use in other scripts
    '
    local SDTMP
    test -f ~/.sdrc || touch ~/.sdrc
    case "$1" in
    -e) # edit nickname db
        vi ~/.sdrc
        ;;
    "") # print .sdrc sorted
        sort ~/.sdrc
        ;;
    -l) # tail .sdrc to get latest
        tail ~/.sdrc
        ;;
    -v) # print what full path of nickname is
        SD_TMP=$(sed -n -e "/^$2 /s/.*  //p" ~/.sdrc)
        test "$SD_TMP" && echo $SD_TMP
        ;;
    -h) # print usage
        echo 'sd [<nick> | -e | -l | -v]
            -e edit db
            -l tail db
            -v expand nick' | sed 's/^  */   /'
        ;;
    *)  # cd to nicknamed folder
        SD_TMP=$(sed -n -e "/^$1 /s/.*  //p" ~/.sdrc)
        test -d "$SD_TMP" && cd "$SD_TMP" && pwd || (
            # add new nickname
            echo -n "add $1 as a shortcut to $PWD? "
            read ok
            echo $ok | grep -q y && (
                # replace existing versions with current one
                grep -v "^$1 " ~/.sdrc > ~/.sd_tmp
                mv ~/.sd_tmp ~/.sdrc
                printf "%-9s  %s\n" $1 "$PWD" | tee -a ~/.sdrc
            )
        )
        ;;
    esac
}
_sd_complete()
{
    COMPREPLY=($(sed -n -e "/^$2/s/  .*//p" ~/.sdrc))
}
complete -F _sd_complete sd
