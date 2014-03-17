VW
==

From *vi whence* - finds and edits the definition of a function among
various configuration files.

#### Synopsis
vw variable

#### Description
Invokes vi on the definition of a variable / function in the
configuration files.  With no variable, produces index of known
functions, aliases, exports.

###### Dependency
Note that [shtags](../master/tools/shtags.py) generates the tags and documentation.  To
work right, match the regular expression therein.  *I.e.*:
+ `func() # about func`
+ `export XX=xxx # about XX`
+ `alias xx=yy # about xx`

See the [sample scripts](../master/base).

#### Features
+ per machine configuration
+ per os configuration
+ sharing of core functions
+ extensible, easy to add additional folders to track and sync scripts
+ minimal home directory clutter

#### Installation
Run `INSTALL`.  Login or exec to activate.  Example:

+ `git clone git@github.com:evanvliet/vw.git`
+ `bash vw/INSTALL`
+ `exec bash`

The install script adds a line to .bashrc to source the *vw*
configuration files.

Many find it useful to synchronize configuration using source
control.  To this end, the `bare` option creates a *git* repository
for sharing.  Do this on a host that provides ssh access to leaf
machines that will share configuration.  Run: 

+ `bash vw/INSTALL bare`

This builds a bare repository in `~/git_root/vw.git` and prints the
git clone command for downsteam access.

#### Notes
See [INDEX.md](../master/INDEX.md) for descirptions of the included
sample functions.  They are an idiosyncratic collection of accumulated
favorites; some, in particular `sd`, `getpass`, and the scrap file
ones, have proven useful over the years; but mostly serve as samples
of how to format code so the *vw* tagging utility finds function
defiinitions.  Note the scripts use a `# +` / `# -` idiom to hold
block comments.  The tagging utility extracts these when generating
documentation.

##### Folders
Keeps configuration files in a directory, typically `vw`, set in
`.bashrc`.  If you move the folder, just rerun `INSTALL` to update
`.bashrc` with the new location.  It has subfolders as follows:
+ base - scripts used everywhere
+ dot - `rc`-type files in your home directory to sync, *e.g.* `.vimrc`.
+ host - machine specific
+ os - os dependent configuration
+ tools - tagging script and data

##### Usage
Most effective when sharing configuration via a base machine holding a
bare repository.  Then, on the leaf machines, the usual *git* pulls,
commits, and pushes from the *vw* directory keep machines in sync.
Also, `vwsync` does a commit, pull, push and check of dot files in
one swell foop.

In addition to `vwsync`, there are these:
+ `vwh` vi host config
+ `vwo` vi os config
+ `vwp` vi vw profile

##### Precedence
`vw` sources files in a deterministic fashion:
1. those in `base`
2. the os configuration, *e.g.*, `os/Linux.sh`
3. the host specific file, *e.g.*, `host/icpu232.sh`

The last one wins, so whatever the host configuration file defines
wins over the os configuration, which in turn overrides whatever is
set up in the base files.  The tags reflect this precedence so `vw`
edits the effective definition.

##### Completion
`vw` supports bash completion, so typing `vw xx<tab><tab>` will show
all *vw* tracked functions, exports or aliases beginning with `xx`.
Same with `huh`.
