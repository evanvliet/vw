#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Reformat bash scripts for tags, indexes, documentation.
"""

import os
import re
import sys
import optparse

reExport = re.compile(r'^export ([A-Za-z]\w+)=.*# (.*)')
reFunction = re.compile(r'^([A-Za-z][\-\.\w]*)( *\()\).*# (.*)')
reAlias = re.compile(r'^alias ([\.A-Za-z][\-\.\w]+)=.*# (.*)')
reBlockStart = re.compile(r'^ *__=')
reBlockEnd = re.compile(r"^ *'")

class TagInfo: # tag info
    def __init__(self, fn, comment='', re=''):
        self.fn = fn
        self.comment = comment
        self.re = re
        self.description = []
    def append(self, info):
        self.description.append(info)

def get_defs(f):
    """Return dict of (file, comment, description) tuples for alias,
    exports, and fundtions defined in f. The description element is an
    array of strings.
    """

    sBlockEnd = ''
    iBlock = -1
    rv = {}
    deftag=''
    comment=''
    fDescription=False
    ti = TagInfo(f)
    for linen in open(f):
        line = linen.rstrip()

        match = reAlias.match(line)
        if match:
            deftag = match.group(1)
            re = r'^alias %s=' % match.group(1)
            rv[deftag] = TagInfo(ti, match.group(2), re)

        match = reExport.match(line)
        if match:
            deftag = match.group(1)
            re = r'^export %s=' % match.group(1)
            rv[deftag] = TagInfo(ti, match.group(2), re)

        match = reFunction.match(line)
        if match:
            deftag = match.group(1)
            re = '^%s%s' % (match.group(1), match.group(2))
            rv[deftag] = TagInfo(ti, match.group(3), re)

        match = reBlockStart.match(line)
        if match:
            iBlock = line.find('__=')
        elif iBlock >= 0:
            # in block quote
            match = reBlockEnd.match(line)
            if match:
                iBlock = -1
            elif deftag:
                rv[deftag].append(line[iBlock:])
            else:
                ti.append(line[iBlock:])
    return rv

def make_tags(xdefs):
    rv = []
    for t in xdefs:
        x = xdefs[t]
        rv.append('%s\t%s\t/%s/' % (t, x.fn.fn, x.re))
    print '\n'.join(sorted(rv))

def make_md(xdefs, fns):
    fn = None
    for f in fns:
        for t in sorted(x for x in xdefs if xdefs[x].fn.fn == f):
            ti = xdefs[t]
            if ti.fn != fn:
                fn = ti.fn
                print '\n###### %s' % fn.fn
                if fn.description:
                    print '\n'.join(fn.description)
            print '* `%s` ' % t ,
            end_dot = '' if ti.comment[-1] == '.' else '.'
            print '%s%s' % (ti.comment, end_dot)
            if ti.description:
                print '\n'.join(ti.description)

def make_summary(xdefs, fns):
    fn = None
    for f in fns:
        for t in sorted(x for x in xdefs if xdefs[x].fn.fn == f):
            ti = xdefs[t]
            if ti.fn != fn:
                fn = ti.fn
                print '-------- %s' % fn.fn
            print '%-8s %s' % (t, ti.comment)

if __name__ == '__main__':
    '''
    print summary of vw funcs
    '''

    op = optparse.OptionParser()  # process command line
    oa = op.add_option
    oa('-m', dest='md', help='generate md description', action='store_true')
    oa('-t', dest='tags', help='tag output', action='store_true')
    oa('-s', dest='summary', help='summary index', action='store_true')
    class opts:
        md = False
        tags = False
        summary = False
    (opts, args) = op.parse_args(sys.argv[1:], opts)

    xdefs = {}
    rv = []
    vw_index = []
    fns = []
    for i in args:
        if os.path.exists(i):
            # update from get_defs info for file
            new_tags = dict(xdefs.items() + get_defs(i).items())
            xdefs = new_tags
            fns.append(i)

    if opts.md:
        make_md(xdefs, fns)
    if opts.tags:
        make_tags(xdefs)
    if opts.summary:
        make_summary(xdefs, fns)
