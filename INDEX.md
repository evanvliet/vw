
###### [base/dev.sh](base/dev.sh)
Development functions. These are rather old, but serve as
examples of what might be convenient.
* `mk`  run make in background.
* `tm`  cat make.log.

###### [base/dtob.sh](base/dtob.sh)
Conversions, both numbers and file names.
* `dtob`  decimal to binary.
* `dtoh`  decimal to hex.
* `htob`  hex to binary.
* `htod`  hex to decimal.
* `tl`  lowercase file names.
* `tu`   upper case file names.

###### [base/ea.sh](base/ea.sh)
Convenient shortcuts.
* `..`  cd ..
* `...`  cd ../..
* `chcount`  character count.
* `cpo`  copy to $OLDPWD.
* `don`  do something a number of time.
For example, use `don 3 echo a` to `echo a` 3 times.
* `ea`  echo all.
Actually echoes just as many file names as will fit on one line.
Good for getting a quick idea of the file population of a folder
without spamming your screen.  Prints `+nn` to show more files
that were not shown.
* `findext`  find by extension.
* `fm`  fm with history.
* `h`  history.
* `llt`  ls latest.
* `lsc`  printable chars.
* `mo`  less -c.
* `num`  phone numbers.
* `r`  redo.
* `root`  be admin.
* `t`  cat.
* `textbelt`  text phone using textbelt.
* `trace`  trace execution of bash script or function.
* `vwclone`  clone project from isp.
* `vwcreate`  make git repository.
* `vwget`  copy from isp xfer folder.
* `vwh`  vi host config.
* `vwo`  vi os config.
* `vwp`  vi vw.profile.
* `vwput`  copy to isp xfer folder.
* `vws`  vi startup.
* `vwsh`  start sh on isp.

###### [base/env.sh](base/env.sh)
Exported variables and an environmnet pretty printer.
* `CDPATH`  include vw in CDPATH.
* `HISTFILE`  bash history.
* `MANPAGER`  manpager opts.
* `PROMPT_COMMAND`  sets window title.
* `PS1`  prompt.
* `PS4`  debug info.
* `VISUAL`  default editor.
* `ep`  expand paths.

###### [base/git.sh](base/git.sh)
A collection of git shortcuts.  Some names influenced by other source
control systems.  Some encapsulate git opts for convenience.  Others
collect common seequences.
* `ci`  git checkin does commit pull and push in one swell foop.
* `co`  per rcs and old times just git checkout.
* `fix_file`  restore file after a merge --no-commit master.
* `gist`  root folder, remote url, and current status.
* `gitbr`  show branch name or delete with -d.
* `lastdiff`  last diff for a file.
* `setconf`  set up a default .gitconfig.

###### [base/isp.sh](base/isp.sh)
Use base machine, *.i.e.*, machine hosting your configuration.  Good on
an isp, ergo the name.
* `isp`  interact with base machine on isp.
Start an ssh session, setup and retrieve git repositories, copy
and paste files. See `isp -h` for usage.

###### [base/pass.sh](base/pass.sh)
Password storage.
* `getpass`  use passsword db.
Do `getpass google` to get your google password.  Depends on
storing line-oriented password data, *e.g.*, `www.google.com
userid password`.  The last word of the line is copied into the
clipboard.  See `getpass -h` for usage.

###### [base/scrap.sh](base/scrap.sh)
Sets up s as a scrap file. For doing stuff like ls > $s and then
editing with vis, *etc*.
Note dependence on wcopy and wpaste which are  os dependent and
set up in os-specific config file.
* `dots`  source scrap.
* `ts`  type scrap.
* `vis`  vi scrap.
* `wcs`  copy clipboard to scrap.
* `wps`  paste scrap to clipbaord.

###### [base/sd.sh](base/sd.sh)
Nicknames for directory navigation.
* `sd`  set directory via nicknames.
Use `sd nick` to cd to folder by nickname `nick`. If `nick`
unknown, save it for the current directory. Without arg, `sd`
lists known nicknames.  Options:
  + `-e` edit db, using vi
  + `-l` tail db, list last added nicknames
  + `-v` expand nick, for use in other scripts

###### [base/vw.sh](base/vw.sh)
Definitions and completion routine for vw and huh.
* `huh`  melange of type typeset alias whence info.
* `vw`  vi whence.

###### [os/Linux.sh](os/Linux.sh)
For linux.
* `browse`  web.
* `gdiff`  gui diff.
* `gdir`  gui files.
* `gedit`  gui editor.
* `vw_key`  machine dependent key.
* `wcopy`  copy to clipboard.
* `wpaste`  paste from clipboard.
