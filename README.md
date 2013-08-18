VW
==
  
From *vi whence* - an old utility to edit the definition of a function
among various configuration files.  It supports using *git* to share
configuration.
  
###SYNOPSIS###
vw [ variable | option ]
  
###DESCRIPTION###
Invokes vi on the definition of a variable / function in the config
files.  With no variable, produces index of known functions, aliases,
exports.  Options, beginning with -, are for internal use by *vw*, see
the source ( *vw vw* ) for details.
  
###FEATURES###
+ per machine config
+ per os config
+ core sharing of functions
+ simple partitioning of customization
+ manageable config files - see vw for 'vi whence' functionality
+ minimal home directory clutter 
+ bloatware - checkout nerd branch, secure password storage, etc.
  
###INSTALLATION###
Clone from Github on a base machine that provides ssh access. Run
INSTALL to set up a bare repository for leaf machines. Go to a leaf
machine. Clone from your base machine. Run INSTALL to set up shared
configuration. Example:

1 base machine set up
<pre>
$ ssh isp@base_machine
$ git clone git@github.com:evanvliet/vw.git
$ bash vw/INSTALL 
Use following to get downstream clone:
git clone isp@base_machine:git_root/vw.git
$ logout
Connection to base_machine closed.
</pre>
2 leaf machine set up
<pre>
$ ssh eric@leaf_machine 
eric@leaf_machine:~$ git clone isp@base_machine:git_root/vw.git
eric@leaf_machine:~$ bash vw/INSTALL
backed up .bashrc
</pre>
3 leaf machine test
<pre>
eric@leaf_machine:~$ exec bash
leaf_machine $ vw

-------- base/vw.sh
huh      show command definition
vw       vi whence

-------- os/Linux.sh
gdir     gui files
gedit    gui editor
$ 
</pre>
  
###NOTES###
Keeps config files in a directory, typically ~/.bashrc.d, set in .bashrc.
It has subfolders as follows:

folder | contents
------ | --------
base   | scripts used everywhere
os     | os dependent config
host   | machine specific
tools  | tagging script and config data

The INSTALL copies .git to your home folder, thus finessing the git
objection to cloning a repository in a non-empty folder.  To keep
git focused, .gitignore starts with '*' to ignore everything and
includes files by adding exception lines, *e.g.,* !file.
Then simple git pulls, commits, and pushes from the home
directory keep shared machines in sync.  See vw --share to add
a new .rc or folder for sharing, e.g., bin.

*VW* sources files in a deterministic fashion, so *vw xx* shows the
effective defintion, picking os or host specific overerides.
