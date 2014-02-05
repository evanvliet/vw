#!/usr/bin/python
# -*- coding: utf-8 -*-

""" mk_passwd [ 2 3 4 5 6 | small | right | large ]

To address idiosyncratic password requirements:
    + small is two limited punc and two digits and 5 alphanumeric
    + right and has two digits and punctuation 11 chars long
    + large is 21 alphanumeric

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

e.g: "mk_passwd 0 0 0 0 11" for 11 out of any printable char.
"""

from random import choice, randint, shuffle
import string
import sys


def make_password(
    alnum=5,
    digit=2,
    punct=2,
    puibm=0,
    ksink=0,
    ):
    """Return a shuffled mix of characters."""

    x0 = ' `\t\n\r\x0b\x0c'  # exclude list
    x1 = x0 + "'`&()|<>"  # more exclusions
    x2 = '!@#$%^&*()' # as per cvs.com password requirements
    list_alnum = string.ascii_letters + string.digits
    list_digit = string.digits
    list_puibm = r"._-"  # least common denominator of punctuation in passwords
    list_punct = list(set(x2)) # usable puncutation
    list_ksink = list(set(string.printable) - set(x0)) # kitchen sink
    a = []
    a.extend(choice(list_alnum) for x in range(alnum))
    a.extend(choice(list_digit) for x in range(digit))
    a.extend(choice(list_punct) for x in range(punct))
    a.extend(choice(list_puibm) for x in range(puibm))
    a.extend(choice(list_ksink) for x in range(ksink))

    # shuffle and prepend letter

    shuffle(a)
    return choice(string.ascii_letters) + ''.join(a)


if __name__ == '__main__':
    """Print password according to options."""
    opt = 'right'
    if sys.argv[1:]: opt = sys.argv[1]
    custom_recipes = None
    if str.isdigit(opt):
        custom_recipes = tuple([int(i) for i in sys.argv[1:]])
    if custom_recipes: print make_password(*custom_recipes)
    if opt == 'small': print make_password(3, 2, 0, 1)
    if opt == 'right': print make_password(5, 3, 2)
    if opt == 'large': print make_password(20, 0, 0)
