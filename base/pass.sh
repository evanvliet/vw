#!/bin/bash
<< 'qp'
Password storage.
qp
getpass() # use passsword db
{
    << 'qp'
    Do `getpass google` to get your google password.  Depends on
    storing line-oriented password data, *e.g.*, `www.google.com
    userid password`.  The last word of the line is copied into the
    clipboard.  See `getpass -h` for usage.

    Note that you can encrypt this data for added security, using
    the `-k` option to set the key.  The key is cached, using
    `vw_key` to encrypt to foil decryption by just copying files
    to another machine.  If you do encrypt the password data, you will
    have to enter the key once on each machine to access the password
    data.
qp
    (
        cd "$VW_DIR/tools/data"
        GP_PLAINTEXT='plaintext'
        GP_PAD='f86199d83fa58cc8988c7aea9a88be19d7a69f0'
        case ${1:--h} in
        --usage) # show help text
            sed 's/^  */  /' <<< 'getpass word | option 
                Search for word in password db. Options:
                -e edit password db
                -g sync with google drive
                -i initialize
                -m merge conflicts
                -k encode with key
                -p make [big|small] password'
            ;;
        --key)  # get / set key to safe
            if test "$2" ; then # set key
                echo "$2$GP_PAD" | openssl des3 -k $(vw_key) > key
            elif test -f key ; then # retrieve key
                openssl des3 -d -k $(vw_key) < key | sed -e s/$GP_PAD//
            else # use plaintext
                echo $GP_PLAINTEXT
            fi
            ;;
        --encrypt) # encrypt passwords and and save in safe
            > safe
            key=$(getpass --key)
            test $key = $GP_PLAINTEXT && mv passwords safe && return
            gzip -c passwords | openssl des3 -k $key > safe
            rm -f passwords
            ;;
        --decrypt) # decrypt safe and put into passwords
            > passwords
            key=$(getpass --key)
            test $key = $GP_PLAINTEXT &&
                file safe | grep -q text &&
                cp safe passwords && return
            test -s safe || return
            ( openssl des3 -k $key -d < safe | zcat > passwords ) 2> /dev/null
            file passwords | grep -q text && return
            read -p 'key: ' NEW_KEY
            getpass --key "$NEW_KEY"
            getpass --decrypt
            ;;
        -e) # edit db - decode, edit, save encrypted if changed
            getpass --decrypt
            cp passwords pass.ref
            vi passwords 
            cmp -s pass.ref passwords || getpass --encrypt
            rm -f passwords
            ;;
        -g) # sync with google drive
            # set -xv
            # get local data into passwords
            getpass --decrypt
            # get google data into pass.ref
            type google &> /dev/null
            test 0 != $? && echo no googlecl && return
            google docs get Passwords pass 2> /dev/null
            test ! -f pass.txt && echo no Passwords on drive && return
            tr -d '\r\200-\377' < pass.txt > pass.ref
            rm pass.txt
            echo >> pass.ref
            # compare and return if no work
            cmp -s pass.ref passwords &&
                rm pass.ref passwords &&
                echo no change &&
                return
            # merge two versions
            diff passwords pass.ref | sed -n '/^> /s//+ /p' > pass.restored
            cat pass.restored passwords > pass.txt
            mv pass.txt passwords
            # user review
            vi passwords
            read -p 'update to google? ' 
            grep -q '^y' <<< $REPLY || return
            # save merged version on google and locally
            google docs edit Passwords --editor "../replace_edit.sh"
            getpass --encrypt
            ;;
        -i) # init db
            rm -f key safe
            echo passwords > passwords
            getpass --encrypt
            ;;
        -m) # merge handling, use our copy but prepend any extra
            getpass --decrypt
            mv passwords pass.ref
            git co --theirs safe
            getpass --decrypt
            diff pass.ref passwords | sed -n '/^> /s//+ /p' > safe
            cat safe pass.ref > passwords
            getpass --encrypt
            ;;
        -n) # encrypt with new key
            getpass --decrypt
            read -p 'key: '
            getpass --key "$REPLY"
            # save in passwords file, deleting former entry
            grep -v ^getpass < passwords > pass.ref
            echo getpass \""$GP_NEW_KEY"\" >> pass.ref
            mv pass.ref passwords
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
            grep -i $1 passwords | tee $s.$$ | tr ';' '\n'
            # copy last word to clipboard as password
            sed -n '$s/.*[; ]//p' $s.$$ | tr -d '\r\n' | wcopy
            rm -f $s.$$ passwords
            ;;
        esac
        rm -f pass.ref pass.restored
    ) # 2> /dev/null
}
