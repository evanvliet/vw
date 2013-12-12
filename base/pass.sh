#!/bin/bash
# +
# Do `getpass google` to get your google password.  Prints matching
# lines from a password list and copies the last word into the
# clipboard.  Does not print the last word, presumably the password,
# as a security precaution.
#
# Use `getpass -e` to edit the password list.  Example:
#
#     www.google.com myname mypassword
#     icpu626 root 789sdf987
#     www.chase.com visa autopay mychaseid mychasepassword
#
# Adding a keyword, *e.g.*, *autopay*, enables retrieving all password
# data associated with that keyword.  This helps if you lose a credit
# card, and need to update web sites.
# -
getpass() # use passsword db
{
    # +
    # Options:
    #   + `-a` add args to passwords
    #   + `-e` edit password list
    #   + `-i` initialize.  To revert to plaintext storage, use `getpass -i`
    #     to reset, then add your previous data.
    #   + `-m` merge conflicts.  If changes are made on different machines,
    #     collisions can occur.  Use `getpass -m` to launch *vi* on a merged
    #     version.
    #   + `-n` encode with new key.  Note that you can encrypt the
    #     data for added security, using the `-n` option to set the
    #     key.  It caches this key, encrpyting with `hostid` to foil
    #     decryption by just copying files to another machine.  If you
    #     do encrypt the password data, you will have to enter the key
    #     once on each machine.  **NB**: this is a homebrew solution and
    #     not vetted for password security.  Use at your own risk.
    #   + `-p` generate new password.  To generate a password, use
    #     `getpass -p`.  Pass an option, *e.g.* `large` or `small`, to
    #     get a longer password, or a shorter and simpler one.  The
    #     default is to satisfy most common requirements of a number,
    #     a punctuation, and mixed case.  Also accepts integer options
    #     for a custom mix of letters, digts and punctation.  See
    #     [mk_passwd.py](tools/mk_passwd.py).
    # -
    pushd "$VW_DIR/tools/data" > /dev/null
    local PAD=jnVedcOrYc5NRPMeqt9sPH6wThh1drwbvCiuKQzHtnpzntuNEO
    case ${1:--h} in
    -a) # append to db
        shift
        _gp_decode
        echo $* >> passwords
        _gp_encode
        ;;
    -e) # edit db - decode, edit, encrypt
        _gp_decode
        vi passwords
        _gp_encode
        ;;
    -i) # init db
        echo google google.pass > getpass.db
        ;;
    -m) # merge handling, use our copy but prepend any extra
        git checkout --theirs getpass.db
        _gp_decode
        mv passwords pass.merge
        _gp_merge pass.merge
        ;;
    -n) # encrypt with new key
        shift
        REPLY="$*"
        test "$REPLY" || read -p 'new key: '
        _gp_decode
        _gp_cache "$REPLY"
        _gp_encode
        ;;
    -p) # password generation
        shift
        "$VW_DIR/tools/mk_passwd.py" $* | wcopy
        wpaste
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
        _gp_decode
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
_gp_merge() # (internal) merge password versions
{
    git checkout --ours getpass.db # our version is the reference
    _gp_decode
    mv passwords pass.ours
    diff pass.ours $1 | sed -n '/^> /s//+ /p' > pass.theirs
    test -s pass.theirs && {
        cat pass.theirs pass.ours > passwords
        vi passwords
        read -p 'update? '
        grep -q ^y <<< "$REPLY" && _gp_encode
    }
    rm -f pass.theirs pass.ours passwords
}
_gp_key() # (internal) get key
{
    test -s getpass.key && openssl des3 -k $(hostid) -d \
        < getpass.key | sed -e s/${PAD::10}.*//
}
_gp_cache() # (internal) cache key
{
    local data="$1$PAD$PAD"
    openssl des3 -k $(hostid) <<< "${data::100}" > getpass.key
}
_gp_encode() # (internal) encrypt passwords in db
{
    cp passwords getpass.db
    local KEY="$(_gp_key)"
    test "$KEY" && openssl des3 -k "$KEY" < passwords > getpass.db
    rm -f passwords
}
_gp_decode() # (internal) decrypt db into passwords
{
    cp getpass.db passwords
    file passwords | grep -q text && rm -f getpass.key
    local KEY="$(_gp_key)"
    until file passwords | grep -q text ; do
        test "$KEY" || read -p 'key: ' KEY
        test "$KEY" || break
        _gp_cache "$KEY"
        openssl des3 -d -k "$KEY" < getpass.db > passwords 2> /dev/null
        KEY=
    done
}
