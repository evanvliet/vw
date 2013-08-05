VW
==
  
From *vi whence* - an old utility to edit the definition of a function among various configuration files.  It supports using *git* to share configuration.
  
###SYNOPSIS###
vw [ variable | option ]
  
###DESCRIPTION###
Invokes vi on the definition of a variable / function in the
config files.  With no variable, produces index of known functions, aliases,
exports.  Options, beginning with -, are for internal use by *vw*, see the source ( *vw vw* ) for details.
  
###FEATURES:###
+ per machine config
+ per os config
+ core sharing of functions
+ simple partitioning of customization
+ manageable config files - see vw for 'vi whence' functionality
+ minimal home directory clutter 
+ stored in VW_DIR
+ bloatware - checkout nerd branch, has secure password storage, other goodies
  
###INSTALLATION:###
Clone from Github on a base machine that provides ssh access. Run INSTALL to set up a bare repository for leaf machines. Go to a leaf machine. Clone from your base machine. Run INSTALL to set up shared configuration. Example:
<pre>
# connect to base machine
$ ssh isp@base_machine
Linux base_machine 3.2.0-4-amd64 #1 SMP Debian 3.2.46-1 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Aug  3 23:24:00 2013 from 10.211.55.2
$ git clone git@github.com:evanvliet/vw.git
Cloning into 'vw'...
remote: Counting objects: 61, done.
remote: Compressing objects: 100% (51/51), done.
remote: Total 61 (delta 3), reused 61 (delta 3)
Receiving objects: 100% (61/61), 21.15 KiB, done.
Resolving deltas: 100% (3/3), done.
$ bash vw/INSTALL 
Use following to get downstream clone:
git clone isp@base_machine:git_root/vw.git
$ logout
Connection to base_machine closed.

# now connect to leaf machine
$ ssh eric@leaf_machine 
eric@leaf_machine:~$ git clone isp@base_machine:git_root/vw.git
Cloning into 'vw'...
remote: Counting objects: 63, done.
remote: Compressing objects: 100% (53/53), done.
remote: Total 63 (delta 4), reused 61 (delta 3)
Receiving objects: 100% (63/63), 21.33 KiB, done.
Resolving deltas: 100% (4/4), done.

# set up vw tree and sharing
eric@leaf_machine:~$ bash vw/INSTALL
backed up .bashrc

# exec bash to pick up vw
eric@leaf_machine:~$ exec bash

# use vw to get index of known functions
leaf_machine $ vw

-------- base/vw.sh
huh      show command definition
vw       vi whence

-------- os/Linux.sh
gdir     gui files
gedit    gui editor
$ 
</pre>
  
###NOTES:###
Keeps config files in a directory, VW_DIR, typically ~/.bashrc.d, set in .bashrc.
It has subfolders as follows:

folder | contents
------ | --------
base   | scripts used everywhere
os     | os dependent config
host   | machine specific
tools  | tagging script and config data
