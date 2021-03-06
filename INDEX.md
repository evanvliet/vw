
###### [base/dev.sh](base/dev.sh)
Development functions. These are rather old, but serve as
examples of what might be convenient.
* `mk`  run make in background.
* `tm`  cat make.log.

###### [base/dtob.sh](base/dtob.sh)
Conversions, both numbers and file names. Dates from looking
at a datascope and dealing with file names on Eunice.
* `dtob`  decimal to binary.
* `dtoh`  decimal to hex.
* `htob`  hex to binary.
* `htod`  hex to decimal.
* `recase`  upper case file names or use -lower to lower case.

###### [base/ea.sh](base/ea.sh)
Convenient shortcuts.
* `..`  cd ..
* `...`  cd ../..
* `cdvw`  cd vw dir.
* `chcount`  character count.
* `cpo`  copy to $OLDPWD.
* `don`  do something a number of times.
For example, use `don 3 echo` to get 3 blank lines.  Default
repetition is `3` and default command is `echo` so acutually,
just `don` does the same.
* `ea`  echo all.
Actually echoes just as many file names as will fit on one line.
Good for getting a quick idea of the file population of a folder
without spamming your screen.  Prints `+nn` to show number of
files that were not listed.
* `findext`  find by extension.
* `fm`  fm with history and sceen width.
* `h`  history.
* `llt`  ls latest.
* `lsc`  printable chars.
* `mo`  less -c.
* `num`  phone numbers.
* `r`  redo.
* `root`  be admin.
* `t`  cat.
* `textbelt`  text phone using textbelt.
* `vimrc`  edit .vimrc.
* `xv`  trace execution of bash script or function.

###### [base/env.sh](base/env.sh)
Exported variables and an environmnet pretty printer.
* `MANPAGER`  manpager opts.
* `PS1`  prompt.
* `PS4`  debug info.
* `PYTHONSTARTUP`  python startup.
* `VISUAL`  default editor.
* `ep`  expand paths.

###### [base/freshgrass.sh](base/freshgrass.sh)
Use vagrant to run the freshgrass vm.
* `freshgrass`  use remote host.

###### [base/git.sh](base/git.sh)
A few git shortcuts.
* `ci`  git checkin does commit pull and push in one swell foop.
* `clone`  for simplicity.
* `co`  per rcs and old times just git checkout.
* `gist`  root folder, remote url, and current status.
* `github_create_repository`  as per github create repository quick setup.
* `setconf`  set up a default .gitconfig.

###### [base/godaddy.sh](base/godaddy.sh)
Workarounds for syncing without git on godaddy.
* `godaddy`  use remote host.

###### [base/isp.sh](base/isp.sh)
Use base machine, *.i.e.*, machine hosting your configuration.  Good
to have on an isp, ergo the name.  The subcommand covers copying files,
running a shell, using git to create, clone repositiories.
* `isp`  interact with base machine.
Subcommands:
  + `get` copy file from xfer folder
  + `put` copy file to xfer folder
  + `shell` run ssh
  + `clone` clone from '$ISP_HOST':~/git_root/'
  + `create` create git repository from working directory

###### [base/pass.sh](base/pass.sh)
Do `getpass google` to get your google password.  Prints matching
lines from a password list and copies the last word into the
clipboard.  Does not print the last word, presumably the password,
as a security precaution.

Use `getpass -e` to edit the password list.  Example:

    www.google.com myname mypassword
    icpu626 root 789sdf987
    www.chase.com visa autopay mychaseid mychasepassword

Adding a keyword, *e.g.*, *autopay*, enables retrieving all password
data associated with that keyword.  This helps if you lose a credit
card, and need to update web sites.
* `getpass`  use passsword db.
Options:
  + `-a` add args to passwords
  + `-e` edit password list
  + `-i` initialize.  To revert to plaintext storage, use `getpass -i`
    to reset, then add your previous data.
  + `-m` merge conflicts.  If changes are made on different machines,
    collisions can occur.  Use `getpass -m` to launch *vi* on a merged
    version.
  + `-n` encode with new key.  Note that you can encrypt the
    data for added security, using the `-n` option to set the
    key.  It caches this key, encrpyting with `hostid` to foil
    decryption by just copying files to another machine.  If you
    do encrypt the password data, you will have to enter the key
    once on each machine.  **NB**: this is a homebrew solution and
    not vetted for password security.  Use at your own risk.
  + `-p` generate new password.  To generate a password, use
    `getpass -p`.  Pass an option, *e.g.* `large` or `small`, to
    get a longer password, or a shorter and simpler one.  The
    default is to satisfy most common requirements of a number,
    a punctuation, and mixed case.  Also accepts integer options
    for a custom mix of letters, digts and punctation.  See
    [mk_passwd.py](tools/mk_passwd.py).
  + `v xxx` verbosely print password for xxx on stdout (vs. the
    default discrete copy to clipboard only.

###### [base/scrap.sh](base/scrap.sh)
Sets up `s` as a scrap file.  For doing stuff like `ls > $s` and
then editing with `vis`, *etc*.  Another common one is to go `h >
$s` and then edit your history with `vis`, turning a sequence of
commands into a shell function.  Then source it with `dots` for
testing and deployment.  Note dependence on `wcopy` and `wpaste`
which are os dependent and set up in os-specific config file.
* `dots`  source scrap.
* `s`  scrap file.
* `ts`  type scrap.
* `vis`  vi scrap.
* `wcs`  copy clipboard to scrap.
* `wps`  paste scrap to clipbaord.

###### [base/sd.sh](base/sd.sh)
Nicknames for directory navigation.  Use `sd nick` to cd to folder
by nickname `nick`.  If `nick` is new, save it for the current
directory. Without a nickname argument, list known nicknames.
* `sd`  set directory via nicknames.
Options:
  + `-e` edit db, using vi
  + `-l` tail db, list last added nicknames
  + `-v` expand `nick`, for use in other scripts

###### [base/vw.sh](base/vw.sh)
Track, sync and edit configuration files.
* `huh`  melange of type typeset alias info.
* `vw`  edit the definition of a function, alias or export.
* `vwdot`  copy vw dot files to home directory.
* `vwfiles`  print config files in order sourced.
* `vwh`  vi host config.
* `vwman`  recap info.
* `vwo`  vi os config.
* `vwp`  vi vw profile.
* `vwsync`  commit new stuff and get latest.

###### [os/Linux.sh](os/Linux.sh)
For linux.
* `browse`  web.
* `gdiff`  gui diff.
* `gdir`  gui files.
* `gedit`  gui editor.
* `wcopy`  copy to clipboard.
* `wpaste`  paste from clipboard.
