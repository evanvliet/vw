VW
==

From *vi whence* - finds and edits the definition of a function
among various configuration files.

#### Synopsis
vw [ variable | option ]

#### Description
Invokes vi on the definition of a variable / function in the config
files.With no variable, produces index of known functions, aliases,
exports.

Options:
  + `--HOST`      host config file
  + `--OS`        OS config file
  + `--dot`       sync dot files
  + `--files`     return nanes of config files in order
  + `--make-tags` make tags for vw scripts
  + `--man`       doc + index
  + `--md`        generate INDEX.md
  + `--sync`      commit new stuff, get latest
  + `--usage`     print usage

###### Dependency
Note that *tools\shtags.py* generates the tags and documentation.
To work right, match the regular expression therein. *I.e.*:
+ function() # comment about function
+ VAR=xxx # comment about var
+ alias xx=yy # comment about alias

See sample scripts.

#### Features
+ per machine config
+ per os config
+ core sharing of functions
+ simple partitioning of customization
+ manageable config files - see vw for 'vi whence' functionality
+ minimal home directory clutter

#### Installation
A two step process.

First set up a repository on a base machine that provides ssh access
to leaf machines.  Just clone this project on that machine. Then
run `INSTALL` with the `bare` option, *i.e.*,
`bash INSTALL bare` to build a bare repository for sharing
by leaf machines. The install script prints the git command for
cloning on a leaf machine.

The second step is to install on leaf machines. Clone from your
base machine, using the command from the base machine install. Run
`bash INSTALL` - without the `bare` option - to set up
`vw`; then `exec bash`, or login, to pick up `vw`. Example:

Step 1.  Base machine set up.
+ `git clone git@github.com:evanvliet/vw.git`
+ `bash vw/INSTALL bare`

This prints the git clone command for access; use it in the next
step when installing on a leaf machine.

Step 2. Leaf machine set up.
+ `git clone isp@base_machine:git_root/vw.git`
+ `bash vw/INSTALL`

This adds a line to .bashrc to source `vw/profile`, and makes
a backup in .bashrc.bak.

#### Notes

##### Samples
See evanvliet/vw/INDEX.md for descirptions of the included
sample functions.

##### Usage
The usual git pulls, commits, and pushes from the vw directory keep
machines in sync.  Also, `vw --sync` does a commit, pull, push and
sync of dot files in one swell foop.

##### Precedence
`VW` sources files in a deterministic fashion, so `vw xx` shows the
effective defintion, respecting os or host configuriation precedence.

##### Folders
Keeps config files in a directory, typically `vw`, set in `.bashrc`.
It has subfolders as follows:

folder | contents
------ | --------
base   | scripts used everywhere
dot    | files to sync with HOME
host   | machine specific
os     | os dependent config
tools  | tagging script and config data
