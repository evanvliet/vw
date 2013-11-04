#!/usr/bin/python
# -*- coding: utf-8 -*-

""" mk_passwd [ 2 3 4 5 6 | big | small | medium ]

To address idiosyncratic password requirements:
    + small is two limited punc and two digits and 5 alphanumeric
    + medium and has two digits and punctuation 11 chars long
    + big is 21 alphanumeric

If no or unrecognized option, medium is the default.  Specify
a custom recipe with integers in the following order, default
values (d) listed below:

no | d | info
---+---+------------------
 1 | 5 | letters or digits
 2 | 2 | digits
 3 | 2 | punctuation marks
 4 | 0 | r"._-" least common denominator
 5 | 0 | any printable

e.g: mk_passwd 0 0 0 0 11 for 11 out of any printable char.
"""

from random import choice, randint, shuffle
import string
import sys


def make_password(
    alnum=5,
    digit=2,
    punc=2,
    pibm=0,
    sink=0,
    ):
    """Return a shuffled mix of characters."""

    chars = string.ascii_letters + string.digits
    x0 = '`\t\n\r\x0b\x0c'  # exclude list
    x1 = x0 + "'`&()|<>"  # more exclusions
    punc0 = r"._-"  # least common denominator of punctuation in passwords
    punc1 = list(set(string.punctuation) - set(x1))
    ok_printable = list(set(string.printable) - set(x0))
    a = []
    a.extend(choice(chars) for x in range(alnum))
    a.extend(choice(string.digits) for x in range(digit))
    a.extend(choice(punc1) for x in range(punc))
    a.extend(choice(punc0) for x in range(pibm))
    a.extend(choice(ok_printable) for x in range(sink))

    # make first char a letter and shuffle rest

    shuffle(a)
    return choice(string.ascii_letters) + ''.join(a)


if __name__ == '__main__':

    pw = make_password(6)  # default
    opt = (sys.argv[1] if sys.argv[1:] else 'medium')
    intargs = tuple([int(i) for i in sys.argv[1:]]) if str.isdigit(opt) else None
    if intargs: pw = make_password(*intargs)
    if opt == 'big': pw = make_password(20, 0, 0)
    if opt == 'small': pw = make_password(4, 2, 0, 2)
    print pw
