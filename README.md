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
  + `--man`       doc + index
  + `--sync`      commit new stuff, get latest

###### Dependency
Note that *tools/shtags.py* generates the tags and documentation.
To work right, match the regular expression therein. *I.e.*:
+ `func() # about func`
+ `XX=xxx # about XX`
+ `alias xx=yy # about xx`

See sample scripts.

#### Features
+ per machine config
+ per os config
+ core sharing of functions
+ simple partitioning of customization
+ manageable config files - see vw for 'vi whence' functionality
+ minimal home directory clutter

#### Installation
Run the INSTALL script. Login or exec to source *vw* configuration
files. Example:

+ `git clone git@github.com:evanvliet/vw.git`
+ `bash vw/INSTALL`
+ `exec bash`

The install script adds a line to .bashrc to source the *vw*
configuration files.

To set up a bare repository on a host that provides ssh access
to leaf machines that will share configuration, run

+ `bash vw/INSTALL bare`

This builds a bare repotistory in `~/git_root/vw.git` and prints the
git clone command for downsteam access.

#### Notes
See [INDEX.md](../master/INDEX.md) for descirptions of the included
sample functions.

##### Folders
Keeps config files in a directory, typically `vw`, set in `.bashrc`.
If you move the folder, just rerun the INSTALL script to update
`.bashrc` with the new location. It has subfolders as follows:
+ base - scripts used everywhere
+ dot - `rc`-type files in your home directory to sync, *e.g.* `.vimrc`.
+ host - machine specific
+ os - os dependent config
+ tools - tagging script and data

##### Usage
Most effective when sharing configuration via a base machine holding
a bare repository. Then, on the leaf machines, the usual git pulls,
commits, and pushes from the vw directory keep machines in sync.
Also, `vw --sync` does a commit, pull, push and sync of dot files
in one swell foop.

##### Precedence
`VW` sources files in a deterministic fashion: 
+ first those in `base`,
+ then the os configuration, *e.g.*, `os/Linux.sh`, 
+ finally the host specific file, *e.g.*, `host/icpu232.sh`. 

The last one wins, so whatever is define in the host config file wins
over the os config version, which in turn overrides whatever is set up
in the base config files. The tags reflect this precdence so `vw` edits
the effective definition.
