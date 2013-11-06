#!/usr/bin/python
# -*- coding: utf-8 -*-


"""fm [ [-s | -a] file ...

A file management tool for maintaining comments about files.

Description:
    Lists files with stored comments. Options:

    -a  prompt for comments for all files, even if there is
        already a comment.

    -s  prompt for comments for only some of the files, those
        without a comment.

    Update file comments with the -a or -s option. When prompting for
    comments, fm recognizes one letter responses as commands to
    inspect the file, or delete it, or go back to the previous one.
    The one letter h response gives usage.

    With neither -a nor -s, fm lists existing comments and names of
    uncommented files.

    A trailing list of file names restricts update or report to just
    those files. If no trailing arguments, it handles all files.
"""

import os
import sys
import glob
import optparse
import readline
import textwrap
import subprocess

USAGE = \
    """Enter comment or a one letter command:
b - go back to previous item
d - get file data; type, ls, first bytes
e - erase existing comment
l - use less to paginate file
m - invoke man on file
q - quit
r - delete file
t - cat file
v - open file with vi"""


def cmd_output(*cmd):
    """Return output of command."""

    try:
        return subprocess.Popen(
                list(cmd),
                stdout=subprocess.PIPE,
                stderr=open('/dev/null', 'w')
            ).communicate()[0]
    except OSError:
        return ''

    
def saved_comments():
    """Return list of unfolded lines from comments db."""

    class CommentInfo(list):
        def __init__(self, fm_db):
            """Build from fm_db data."""
            line = ''
            nline = ''
            for line in fm_db:
                if line[0] == ' ':
                    nline = '%s %s' % (nline, line.strip())
                else:
                    self.append(nline)
                    nline = line
            self.append(nline)
        def comment_for_name(self, fn, remove=False):
            """Return comment for filename.  If remove, purge line from
            data to prevent two files having same comment, e.g.,
            "Apps" and "Apps (Parallels)".  Useful if picking up
            comments in reverse lexicographic order, so longer matches
            consume comments first."""
            prefix = '%s ' % fn
            for s in self:
                if s.startswith(prefix):
                    if remove:
                        self.remove(s)
                    return s[len(prefix):].strip()
            return ''

    return CommentInfo(db_handle())

def save_comments(data):
    """Write new comment data."""

    db_handle('w').write(data)

def db_handle(mode='r'):
    """Get file, use .fm if writable, else munged full path in ~/.fmdb."""

    f = open('/dev/null', mode)  # fallback file handle
    try:
        f = open('.fm', mode)  # default use .fm
    except:
        home = os.environ.get('HOME')  # build munged name
        fmdb = '.fmdb'
        persist = os.environ.get('PWD').replace('/', '_')
        fn = '%s/%s/%s' % (home, fmdb, persist)
        try:
            f = open(fn, mode)  # try munged name
        except:  # try making directory
            cmd_output('mkdir', '-p', '%s/%s' % (home, fmdb))
            try:
                f = open(fn, mode)
            except:
                pass  # give up and return fallback
    return f

class FileComment:

    """Hold comment and selection status for one file."""

    history = []
    bold = cmd_output('tput', 'setaf', '5').strip()
    sgr0 = cmd_output('tput', 'sgr0').strip()
    cols = int(os.getenv('COLUMNS', '80'))

    @staticmethod
    def load_history():
        """Load history info."""

        histfile = os.environ.get('HISTFILE')
        if histfile and os.path.exists(histfile):
            FileComment.history = open(histfile).readlines()

    def __init__(self, name):
        self.comment = ''
        self.selected = True
        self.name = name
        self.history = 0

    def __repr__(self):
        """Return name and comment wrapped."""

        return '\n'.join(textwrap.TextWrapper(
                width=FileComment.cols,
                subsequent_indent=10 * ' '
            ).wrap('%-9s %s' % (self.name, self.comment)))

    def hist(self):
        """Return history info for self."""

        if self.history == 0:
            return ''
        def _emphasize(s):
            return s.replace(self.name, '%s%s%s' % (
                FileComment.bold, self.name, FileComment.sgr0))
        a = ['']
        a.extend(FileComment.history[self.history - 3:self.history + 4])
        return '  $ '.join(_emphasize(s) for s in a)

    def update(self, inc):
        """Update comment, handle commands. Return position increment."""

        rv = 0  # position increment default is do same again
        if not os.path.exists(self.name):
            self.selected = False
        if not self.selected:
            return inc
        if self.comment:
            print self
            readline.add_history(self.comment)
        try:
            comment = raw_input('%s: ' % self.name)
        except (KeyboardInterrupt, EOFError):
            print   # newline
            return 2  # return quit signal
        if len(comment) == 0:  # pass to next
            rv = 1  # next
        elif len(comment) > 1:  # save as comment
            readline.add_history(comment)
            self.comment = comment
            rv = 1  # next
        elif comment == 'b':  # go back one
            rv = -1  # previous
        elif comment == 'd':  # get data
            print self.hist() ,
            print ' '.join(cmd_output('ls', '-dl', self.name).split()[:8]) ,
            nlines = cmd_output('wc', '-l', self.name)[1:].split() or ['?']
            print '%s lines' % nlines[0]
            print ' '.join(cmd_output('file', self.name).split(':')[1:]).strip()
            print cmd_output('env', '-i', 'od', '-cN64', '-An', self.name)
        elif comment == 'e':  # erase existing comment
            self.comment = ''
            rv = 1  # next
        elif comment == 'l':  # use less to paginate file
            subprocess.call(['less', self.name])
        elif comment == 'm':  # use less to paginate file
            subprocess.call(['man', self.name])
        elif comment == 'q':  # quit
            rv = 2  # quit signal
        elif comment == 'r':  # delete
            cmd_output('rm', '-rf', self.name)
            rv = 1  # next
        elif comment == 't':  # cat
            print open(self.name).read().rstrip()
        elif comment == 'v':  # open with vi
            subprocess.call(['vim', self.name])
        else:
            print USAGE
        return rv


class FileComments(dict):

    """A dict of FileComment objects, indexed by filename."""

    def __init__(self):
        """Load file names and saved comments."""

        for fn in glob.glob('*'):  # build entries for current files
            self[fn] = FileComment(fn)

        saved = saved_comments()  # add saved comments
        for fn in sorted(self, reverse=True):
            self[fn].comment = saved.comment_for_name(fn, remove=True)

    def __repr__(self):
        """Returns comments."""

        return '\n'.join("%s" % self[x] for x in self.commented_ones())

    def uncommented_files_summary(self):
        """Report uncommented files with :: prefix."""

        ucf = sorted(set(self.selected_ones()) - set(self.commented_ones()))
        summary = []
        rv = []
        line = '::'
        while ucf:  # build lines of uncommented file names
            fn = ucf.pop(0)
            if fn:
                xline = '%s %s' % (line, fn)  # append name
                if len(xline) < FileComment.cols:  # fits
                    line = xline
                else:  # start new line
                    rv.append(line)  # save accumulated line
                    if len(rv) > 3:  # stop after  three lines
                        if ucf:  # note how many more in summary
                            summary = [':: +%d' % len(ucf)]
                        break
                    line = ':: %s' % fn  # start next line of file names
        summary = summary or [line] if len(line) > 3 else []
        return '\n'.join(rv[:3] + summary)

    def commented_ones(self):
        """Return commented subset."""

        return sorted(x for x in self if self[x].comment)

    def selected_ones(self):
        """Return selected subset."""

        return sorted(x for x in self if self[x].selected)

    def show_comments(self):
        """Renders comments and lists uncommented files."""

        selcom = sorted(set(self.selected_ones()) & set(self.commented_ones()))
        cf = '\n'.join(str(self[x]) for x in selcom)
        ucf = self.uncommented_files_summary()
        if cf and ucf:
            cf += '\n\n'
        if cf or ucf:
            print cf + ucf

    def update_comments(self):
        """Get comments for selected files."""

        # load history info
        FileComment.load_history()
        selected_set = set(self.selected_ones())
        for (i, l) in enumerate(FileComment.history):
            for fn in set(l.split()) & selected_set:
                self[fn].history = i  # last history ref to fn

        # update selected files
        selected_list = self.selected_ones()
        (pos, inc, num) = (0, 1, len(selected_list))
        while pos < num:
            fn = selected_list[pos]
            inc = self[fn].update(inc)
            pos = max(0, pos + inc)  # increment position
            if inc > 1:
                break  # quit signal
            elif inc == 1:
                save_comments('%s\n' % self)  # save comment
            elif inc < 0 and pos == 0:
                inc = 1  # already at beginning


if __name__ == '__main__':
    '''Collect options and report or update accordingly.'''

    op = optparse.OptionParser()  # process command line
    oa = op.add_option
    oa('-s', dest='some', help='review some', action='store_true')
    oa('-a', dest='update', help='review all', action='store_true')
    class Opts:
        update = False  # update comments
        some = False  # only files without comments
    (Opts, args) = op.parse_args(sys.argv[1:], Opts)

    fc = FileComments()  # one FileComment for each file in working directory

    if args:  # skip files not on command line
        for fn in set(fc) - set(args):
            fc[fn].selected = False

    if Opts.some:  # skip files with comment
        for fn in fc.commented_ones():
            fc[fn].selected = False

    if Opts.some or Opts.update:
        fc.update_comments()
    else:
        fc.show_comments()
