#!/bin/bash
# +
# Nicknames for directory navigation.  Use `sd nick` to cd to folder
# by nickname `nick`.  If `nick` is new, save it for the current
# directory. Without a nickname argument, list known nicknames.
# -
sd() # set directory via nicknames
{
    # +
    # Options:
    #   + `-e` edit db, using vi
    #   + `-l` tail db, list last added nicknames
    #   + `-v` expand `nick`, for use in other scripts
    # -
    local SD_LIST=~/.sdrc
    local SD_DIR
    test -f $SD_LIST || > $SD_LIST
    case "$1" in
    "") # sorted list
        sort $SD_LIST
        ;;
    -e) # edit list
        vi $SD_LIST
        ;;
    -l) # last added
        tail $SD_LIST
        ;;
    -v) # verify nickname
        test "$2" && SD_DIR=$(sed -n -e "/^$2 /s/.*  //p" $SD_LIST)
        test "$SD_DIR" && echo $SD_DIR
        ;;
    -h) # help
        sed 's/^  */   /' <<< 'sd [<nick> | -e | -l | -v]
            -e edit db
            -l tail db
            -v expand nick'
        ;;
    *) # default look up and either cd or add new nickname
        SD_DIR=$(sed -n -e "/^$1 /s/.*  //p" $SD_LIST)
        test -d "$SD_DIR" && cd "$SD_DIR" && pwd && return
        # add new nickname
        read -p "add $1 as a shortcut to $PWD? "
        grep -q y <<< $REPLY || return
        # replace existing versions with current one
        grep -v "^$1 " $SD_LIST > $SD_LIST$$
        mv $SD_LIST$$ $SD_LIST
        printf "%-9s  %s\n" $1 "$PWD" >> $SD_LIST
        tail -1 $SD_LIST
        ;;
    esac
}
_sd_complete() { COMPREPLY=($(sed -n -e "/^$2/s/ .*//p" ~/.sdrc)) ; }
complete -F _sd_complete sd
