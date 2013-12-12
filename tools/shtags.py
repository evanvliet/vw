#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Create tags and documentation for shell scripts.
Usage:
    shtags.py [-t | -m | -s ] file ....
    options:
        -t tagfile
        -m markdown index
        -s brief text
"""

import os
import re
import sys


# Patterns that match definitions and block quotes.

reExport = re.compile(r'^export ([A-Za-z]\w*)=.*# (.*)')
reFunction = re.compile(r'^([A-Za-z][\-\.\w]*)( *\()\).*# (.*)')
reAlias = re.compile(r'^([ \t]*alias )([\.A-Za-z][\-\.\w]*)=(.*)')
reBlockStart = re.compile(r"^ *# \+")
reBlockEnd = re.compile(r"^ *# \-")


class TagInfo:  # hold info for a tag to create tags file

    def __init__( self, fn, comment='', re='',):
        self.fn = fn  # TagInfo object for file
        self.comment = comment  # from end of line
        self.re = re  # regular expression to use in tags
        self.description = []  # from block comments

    def append(self, info):
        self.description.append(info)

def get_defs(f):
    """Return dict of TagInfo's for each definition in f.
    """

    iBlock = -1  # flag for in blockquote, >= 0 for yes
    rv = {}  # return value is a dictionary
    deftag = ''  # defined tag current function alias export
    comment = ''  # comment at end of line
    ti = TagInfo(f)
    for linen in open(f):
        line = linen.rstrip()

        if iBlock >= 0:  # in block quote
            match = reBlockEnd.match(line)

            # append to deftag info, or ti as default
            # note slicing of iBlock characters, to
            # handle indented comment

            if match:
                iBlock = -1
            elif deftag:
                rv[deftag].append(line[iBlock:])
            else:
                ti.append(line[iBlock:])
            continue

        match = reBlockStart.match(line)
        if match:

            # set iBlock to len('# ') + the number of leading
            # spaces ergo the index to where a possibly
            # indented comment starts

            iBlock = 2 + len(line) - len(line.lstrip(' '))
            continue

        match = reAlias.match(line)
        if match:
            deftag = match.group(2)
            re = r'^%s%s=' % (match.group(1), match.group(2))
            comment = match.group(3)
            k = comment.find('# ')
            if k:
                comment = comment[k+2:]
            if len(comment) > 20:
                comment = comment[:15] + ' ...'
            rv[deftag] = TagInfo(ti, comment, re)
            continue

        match = reExport.match(line)
        if match:
            deftag = match.group(1)
            re = r'^export %s=' % match.group(1)
            rv[deftag] = TagInfo(ti, match.group(2), re)
            continue

        match = reFunction.match(line)
        if match:
            deftag = match.group(1)
            re = '^%s%s' % (match.group(1), match.group(2))
            rv[deftag] = TagInfo(ti, match.group(3), re)

    return rv


def get_fns(defs):
    """Return file names for defs in dict of TagInfos.
    """
    return sorted(set(defs[x].fn.fn for x in defs))


def make_tags(defs):
    """Write vi suitable tags file."""

    rv = []
    for t in defs:
        x = defs[t]
        rv.append('%s\t%s\t/%s/' % (t, x.fn.fn, x.re))
    print '\n'.join(sorted(rv))


def make_markdown(defs):
    """Block comments in markdown format."""

    fn = None
    for f in get_fns(defs):
        for t in sorted(x for x in defs if defs[x].fn.fn == f):
            ti = defs[t]
            if ti.fn != fn:
                fn = ti.fn
                print '\n###### [%s](%s)' % (fn.fn, fn.fn)
                if fn.description:
                    print '\n'.join(fn.description)
            print '* `%s` ' % t,
            comment = ti.comment or 'from %s' % ti.fn.fn
            end_dot = ('' if comment[-1] == '.' else '.')
            print '%s%s' % (comment, end_dot)
            if ti.description:
                print '\n'.join(ti.description)


def make_summary(defs):
    """Plain text summary from comments."""

    fn = None
    for f in get_fns(defs):
        for t in sorted(x for x in defs if defs[x].fn.fn == f):
            ti = defs[t]
            if ti.fn != fn:
                fn = ti.fn
                print '-------- %s' % fn.fn
            print '%-8s %s' % (t, ti.comment)


if __name__ == '__main__':

    defs = {}  # dictionary of definitions
    for f in filter(os.path.exists, sys.argv[2:]):
        defs.update(get_defs(f))  # accumulate tag info

    make = { # options map to make operations
        '-m': make_markdown,
        '-t': make_tags,
        '-s': make_summary }

    try:
        opt = sys.argv[1]
        make[opt](defs)
    except:
        print __doc__
