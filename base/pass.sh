#!/bin/bash
# +
# Do `getpass google` to get your google password.  Prints matching
# lines from a password list and copies the last word into the
# clipboard.  Does not print the last word, presumably the password,
# as a security precaution.  Use `getpass -e` to edit the password
# list.  Example:
#
#     www.google.com myname mypassword
#     icpu626 root 789sdf987
#     www.chase.com visa autopay mychaseid mychasepassword
#
# Note that you can encrypt the data for added security, using the `-n`
# option to set the key.  It caches this key, encrpyting with `hostid`
# to foil decryption by just copying files to another machine.  If you
# do encrypt the password data, you will have to enter the key once on
# each machine.
#
# If different changes are made on different machines, collisions
# can occur.  Use `getpass -m` to launch *vi* on a merged version.
#
# To revert to plaintext storage, use `getpass -i` to reset, then add
# your previous data.
#
# Adding a keyword, *e.g.*, *autopay*, enables retrieving all password
# data associated with that keyword.  This helps if you lose a credit
# card, and need to update web sites.
#
# To generate a password, use `getpass -p`.  Pass an option, *e.g.*
# `large`, `small` or `right` to get one that's too big, too
# small, or just right.  Also accepts integer options for a custom
# mix of letters, digts and punctation.  See *tools/mk_passwd.py*.
# -
getpass() # use passsword db
{
    pushd "$VW_DIR/tools/data" > /dev/null
    local PAD=$(hostid)jlaskdjfaldskjaldkjfaldskjfaldkjalsdfjaljk
    case ${1:--h} in
    -a) # append to db
        shift
        getpass --decode
        echo $* >> passwords
        getpass --encode
        ;;
    -e) # edit db - decode, edit, encrypt
        getpass --decode
        vi passwords
        getpass --encode
        ;;
    -i) # init db
        rm -f getpass.key getpass.db
        echo google google.pass > passwords
        getpass --encode
        ;;
    -m) # merge handling, use our copy but prepend any extra
        test -s pass.new && cp pass.new pass.merge || { # use pass.new
            # or git version
            git co --theirs getpass.db
            getpass --decode
            mv passwords pass.merge
        }
        getpass --decode
        cp passwords pass.tmp
        diff passwords pass.merge | sed -n '/^> /s//+ /p' > getpass.db
        cat getpass.db pass.tmp > passwords
        cmp passwords pass.tmp && echo no change && return
        vi passwords
        read -p 'update? '
        test -z "${REPLY##y*}" -a -s pass.new && cp passwords pass.new
        getpass --encode
        ;;
    -n) # encrypt with new key
        shift
        REPLY="$*"
        test "$REPLY" || read -p 'new key: '
        getpass --decode
        getpass --cache "$REPLY"
        getpass --encode
        ;;
    -p) # password generation
        shift
        "$VW_DIR/tools/mk_passwd.py" $* | wcopy
        wpaste
        ;;
    --key) # internal get key
        openssl des3 -k $(hostid) -d < getpass.key | sed -e s/$PAD//
        ;;
    --cache) # internal cache key
        openssl des3 -k $(hostid) <<< "$PAD$2" > getpass.key
        ;;
    --encode) # internal encrypt passwords in db
        test ! -s getpass.key && cp passwords getpass.db ||
        openssl des3 -k "$(getpass --key)" < passwords > getpass.db
        rm -f passwords
        ;;
    --decode) # internal decrypt db into passwords
        test ! -s getpass.key && cp getpass.db passwords ||
        openssl des3 -k "$(getpass --key)" -d \
            < getpass.db > passwords 2> /dev/null
        while file passwords | grep -qv text ; do
            read -p 'key: '
            test "$REPLY" || break
            getpass --cache "$REPLY"
            openssl des3 -k "$(getpass --key)" -d \
                < getpass.db > passwords 2> /dev/null
        done
        ;;
    -*) # show help text
        sed 's/^  */  /' <<< 'getpass [ word | option ]
            Search for word in password list.  Options:
            -a add args to passwords
            -e edit password list
            -i initialize
            -m merge conflicts
            -n encode with new key
            -p opt make password opt = [small | right | large]'
        ;;
    *) # default prints matching lines from db
        getpass --decode
        grep -i $1 passwords > pass.tmp
        # copy last word of last match to clipboard as password
        sed -n '$s/.*[; ]//p' pass.tmp | tr -d '\r\n' | wcopy
        # and print all but last word for security
        sed 's/.[^; ]*$//' pass.tmp | tr ';' '\n'
        rm -f passwords
        ;;
    esac
    rm -f pass.tmp pass.merge
    popd > /dev/null
}
