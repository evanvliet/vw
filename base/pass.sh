#!/bin/bash
# +
# Do `getpass google` to get your google password.  Prints matching
# lines from a password list and copies the last word into the
# clipboard.  Use `getpass -e` to edit the password list.
#
# Note that you can encrypt the data for added security, using the `-n`
# option to set the key.  It caches this key, encrpyting with `vw_key`
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
# Adding a keyword, *e.g.*, *autopay*, to enable retrieving all password
# data associated with that keyword.  This helps if you lose a credit
# card, and need to update web sites.
# -
getpass() # use passsword db
{
    local PASSKEY=$VW_DIR/tools/data/key
    local PASSDB=$VW_DIR/tools/data/safe
    local PASSWORDS=$VW_DIR/tools/data/passwords
    local PLAINTEXT='plaintext'
    trap 'test "$PASSWORDS" && rm -f $PASSWORDS.*' RETURN
    case ${1:--h} in
    --usage) # show help text
        sed 's/^  */  /' <<< 'getpass [ word | option ]
            Search for word in password list.  Options:
            -e edit password list
            -i initialize
            -m merge conflicts
            -n encode with new key
            -p make [big|small] password'
        ;;
    --key)  # get / set key to safe
        local PAD=$(vw_key)bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
        if test "$2" ; then # set key
            echo "$2$PAD" | openssl des3 -k $(vw_key) > $PASSKEY
        elif test -f $PASSKEY ; then # retrieve key
            openssl des3 -d -k $(vw_key) < $PASSKEY | sed -e s/$PAD//
        else # use plaintext
            echo $PLAINTEXT
        fi
        ;;
    --encrypt) # encrypt passwords and and save in safe
        > $PASSDB
        local KEY=$(getpass --key)
        test $KEY = $PLAINTEXT && mv $PASSWORDS $PASSDB && return
        gzip -c $PASSWORDS | openssl des3 -k $KEY > $PASSDB
        rm -f $PASSWORDS
        ;;
    --decrypt) # decrypt safe and put into passwords
        while true ; do
            > $PASSWORDS
            local KEY=$(getpass --key)
            test $KEY = $PLAINTEXT &&
                file $PASSDB | grep -q text &&
                cp $PASSDB $PASSWORDS && break
            test -s $PASSDB || break
            ( openssl des3 -k $KEY -d < $PASSDB | zcat > $PASSWORDS ) &> /dev/null
            test -s $PASSWORDS && file $PASSWORDS | grep -q text && break
            read -p 'key: '
            test "$REPLY" || break
            getpass --key "$REPLY"
        done
        ;;
    -e) # edit db - decode, edit, save encrypted if changed
        getpass --decrypt
        cp $PASSWORDS $PASSWORDS.tmp
        cd $(dirname $PASSWORDS)
        vi $(basename $PASSWORDS)
        cd - &> /dev/null
        cmp -s $PASSWORDS.tmp $PASSWORDS || getpass --encrypt
        rm -f $PASSWORDS
        ;;
    -i) # init db
        rm -f key $PASSDB
        echo google google.pass > $PASSWORDS
        getpass --encrypt
        ;;
    -m) # merge handling, use our copy but prepend any extra
        getpass --decrypt
        mv $PASSWORDS $PASSWORDS.tmp
        git co --theirs $PASSDB
        getpass --decrypt
        diff $PASSWORDS.tmp $PASSWORDS | sed -n '/^> /s//+ /p' > $PASSDB
        cat $PASSDB $PASSWORDS.tmp > $PASSWORDS
        getpass --encrypt
        ;;
    -n) # encrypt with new key
        getpass --decrypt
        read -p 'key: '
        getpass --key "$REPLY"
        # save in passwords file, deleting former entry
        grep -v ^getpass < $PASSWORDS > $PASSWORDS.tmp
        echo getpass "$REPLY" >> $PASSWORDS.tmp
        mv $PASSWORDS.tmp $PASSWORDS
        getpass --encrypt
        ;;
    -p) # password generation
        "$VW_DIR/tools/mk_passwd.py" $2
        ;;
    -*)
        getpass --usage
        ;;
    *) # default prints matching lines from db
        getpass --decrypt 
        grep -i $1 $PASSWORDS | tee $PASSWORDS.tmp | tr ';' '\n'
        # copy last word to clipboard as password
        sed -n '$s/.*[; ]//p' $PASSWORDS.tmp | tr -d '\r\n' | wcopy
        rm -f $PASSWORDS
        ;;
    esac
}
