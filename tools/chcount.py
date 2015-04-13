#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
usage: chcount.py [-u] [file ...]

Lists each character with non-zero count along with count. Non-printable
characters have ASCII labels or meta-char escapes, as per python
curses.ascii.

The -u option reports only unused byte codes.

Usual read of files from command line args or stdin if none.
'''

import sys
import curses.ascii
label = [curses.ascii.controlnames[i] for i in range(33)]
label.extend([curses.ascii.unctrl(i) for i in range(33, 128)])
label.extend(['#%02X' % i for i in range (128, 256)])


def charcnt(f, char_counts):
    '''Accumulate character counts from file.'''

    chunk = "data"
    while chunk:
        chunk = f.read(8192)
        for byte in chunk:
            char_counts[ord(byte)] += 1


if __name__ == '__main__':
    char_counts = [0 for i in range(256)]
    args = sys.argv[1:]
    unused_codes = False
    try:
        if args and args[0] == '-u':
            unused_codes = True
            args = args[1:]
        for fn in args:
            f = open(fn)
            charcnt(f, char_counts)
        if not args:
            charcnt(sys.stdin, char_counts)
    except Exception, e:
        sys.stderr.write('%s\n' % e)
        sys.stderr.write('%s\n' % __doc__)
        sys.exit(1)

    for (code, count) in enumerate(char_counts):
        if unused_codes and count == 0:
            print '%04o %-4s' % (code, label[code])
        if ( not unused_codes ) and ( count > 0 ):
            print '%7d %-4s' % (count, label[code])
