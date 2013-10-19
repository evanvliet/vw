#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
usage: chcount.py [file ...]

Lists each character with non-zero count along with count. Non-printable
characters have ASCII labels or meta-char escapes, as per python
curses.ascii.

Usual read of files from command line args or stdin if none.
'''

import sys
import curses.ascii


def charcnt(f, char_counts):
    '''Accumulate character counts from file.'''

    byte = f.read(1)
    while byte:
        char_counts[ord(byte)] += 1
        byte = f.read(1)


if __name__ == '__main__':
    char_counts = [0 for i in range(256)]
    try:
        if sys.argv[1:]:
            for fn in sys.argv[1:]:
                f = open(fn)
                charcnt(f, char_counts)
        else:
            charcnt(sys.stdin, char_counts)
    except Exception, e:
        sys.stderr.write('%s\n' % e)
        sys.stderr.write('%s\n' % __doc__)
        sys.exit(1)

    for (code, count) in enumerate(char_counts):
        if count > 0:
            label = curses.ascii.unctrl(code)
            if code <= 32:
                label = curses.ascii.controlnames[code]
            if code >= 128:
                label = '\\%03o' % code
            print '%7d %-4s' % (count, label)
    sys.exit(0)
