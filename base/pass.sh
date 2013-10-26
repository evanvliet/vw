#!/bin/bash
# +
# Password storage.
# 
# Note that you can encrypt the data for added security, using the `-n`
# option to set the key.  It caches this key, encrpyting with `vw_key`
# to foil decryption by just copying files to another machine.  If you
# do encrypt the password data, you will have to enter the key once on
# each machine.
# -
getpass() # use passsword db
{
    # +
    # Do `getpass google` to get your google password.  Depends on
    # storing line-oriented password data, *e.g.*, `www.google.com
    # userid password`.  The last word of the line is copied into the
    # clipboard.  See `getpass -h` for usage.
    # -
    local PASSKEY=$VW_DIR/tools/data/key
    local PASSDB=$VW_DIR/tools/data/safe
    local PASSTMP=$VW_DIR/tools/data/pass$$
    local PASSWORDS=$VW_DIR/tools/data/passwords
    local PLAINTEXT='plaintext'
    trap 'rm -f $PASSTMP*' RETURN
    case ${1:--h} in
    --usage) # show help text
        sed 's/^  */  /' <<< 'getpass [ word | option ]
            Search for word in password list.  Options:
            -e edit password list
            -g sync with google drive
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
        cp $PASSWORDS $PASSTMP
        cd $(dirname $PASSWORDS)
        vi $(basename $PASSWORDS)
        cd - &> /dev/null
        cmp -s $PASSTMP $PASSWORDS || getpass --encrypt
        rm -f $PASSWORDS
        ;;
    -g) # sync with google drive
        # set -xv
        # get local data into passwords
        getpass --decrypt
        # get google data into $PASSTMP
        type google &> /dev/null
        test 0 != $? && echo no googlecl && return
        google docs get Passwords $PASSTMP 2> /dev/null
        test ! -f $PASSTMP.txt && echo no Passwords on drive && return
        tr -d '\r\200-\377' < $PASSTMP.txt > $PASSTMP
        rm $PASSTMP.txt
        echo >> $PASSTMP
        # compare and return if no work
        cmp -s $PASSTMP $PASSWORDS &&
            rm $PASSTMP $PASSWORDS &&
            echo no change &&
            return
        # merge two versions
        diff $PASSWORDS $PASSTMP | sed -n '/^> /s//+ /p' > $PASSTMP.restored
        cat $PASSTMP.restored $PASSWORDS > $PASSTMP.txt
        mv $PASSTMP.txt $PASSWORDS
        # user review
        vi $PASSWORDS
        read -p 'update to google? ' 
        grep -q '^y' <<< $REPLY || return
        # save merged version on google and locally
        cd $(dirname $PASSWORDS)
        google docs edit Passwords --editor "../replace_edit.sh"
        cd - &> /dev/null
        getpass --encrypt
        ;;
    -i) # init db
        rm -f key $PASSDB
        echo google google.pass > $PASSWORDS
        getpass --encrypt
        ;;
    -m) # merge handling, use our copy but prepend any extra
        getpass --decrypt
        mv $PASSWORDS $PASSTMP
        git co --theirs $PASSDB
        getpass --decrypt
        diff $PASSTMP $PASSWORDS | sed -n '/^> /s//+ /p' > $PASSDB
        cat $PASSDB $PASSTMP > $PASSWORDS
        getpass --encrypt
        ;;
    -n) # encrypt with new key
        getpass --decrypt
        read -p 'key: '
        getpass --key "$REPLY"
        # save in passwords file, deleting former entry
        grep -v ^getpass < $PASSWORDS > $PASSTMP
        echo getpass "$REPLY" >> $PASSTMP
        mv $PASSTMP $PASSWORDS
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
        grep -i $1 $PASSWORDS | tee $PASSTMP | tr ';' '\n'
        # copy last word to clipboard as password
        sed -n '$s/.*[; ]//p' $PASSTMP | tr -d '\r\n' | wcopy
        rm -f $PASSTMP $PASSWORDS
        ;;
    esac
}
