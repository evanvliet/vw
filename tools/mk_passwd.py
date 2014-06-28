#!/usr/bin/python
# -*- coding: utf-8 -*-

""" [ small | right | large | <custom>]

Generate passwords according to recipe:
    + small is one limited punc and two digits and 3 letters
    + right and has five letters and three digits two punctuation
    + large is 20 alpha and 12 digits
    + custom recipe is sequence of up to five digits for different character types:

 1 | letters
 2 | digits
 3 | punctuation marks
 4 | r"._-" least common denominator
 5 | any printable
---+------------------
e.g.:
    small is 3 2 0 1
    right is 5 3 2
    large is 20 12 0
"""

from random import choice, randint, shuffle
import string
import sys


def make_password(
    alpha=0,
    digit=0,
    punct=0,
    puibm=0,
    ksink=0,
    ):
    """Return a shuffled mix of characters."""

    x0 = "' `\t\n\r\x0b\x0c"  # exclude list
    x1 = x0 + "'`&()|<>"  # more exclusions
    x2 = '!@#$%^&*()' # as per cvs.com password requirements
    list_alpha = string.ascii_letters
    list_digit = string.digits
    list_puibm = r"._-"  # least common denominator of punctuation in passwords
    list_punct = list(set(x2)) # usable puncutation
    list_ksink = list(set(string.printable) - set(x0)) # kitchen sink
    a = []
    a.extend(choice(list_alpha) for x in range(alpha))
    a.extend(choice(list_digit) for x in range(digit))
    a.extend(choice(list_punct) for x in range(punct))
    a.extend(choice(list_puibm) for x in range(puibm))
    a.extend(choice(list_ksink) for x in range(ksink))

    shuffle(a)
    return ''.join(a)


if __name__ == '__main__':
    """Print password according to options."""
    opt = 'help'
    if sys.argv[1:]: opt = sys.argv[1]
    custom_recipes = None
    if str.isdigit(opt):
        custom_recipes = tuple([int(i) for i in sys.argv[1:]])
    if custom_recipes: print make_password(*custom_recipes)
    if opt == 'small': print make_password(3, 2, 0, 1)
    if opt == 'right': print make_password(5, 3, 2)
    if opt == 'large': print make_password(20, 10, 0)
    if opt == 'help': print __doc__
