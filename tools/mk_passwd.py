#!/usr/bin/python

from random import choice, randint, shuffle
import string
import sys

def make_password(opt='x'):
    chars = string.ascii_letters + string.digits
    x = r'`&()|<>'  # exclude list
    punc = r"_=,*~+."
    punc = list(set(string.punctuation) - set(x))
    pibm = r"._-" # least common denominator of punctuation in passwords
    a = []
    if opt == 'small':
        a.extend("".join(choice(pibm) for x in range(2)))
        a.extend("".join(choice(string.digits) for x in range(2)))
        a.extend("".join(choice(chars) for x in range(3)))
        shuffle(a)
        a = choice(string.ascii_letters) + "".join(a)
    elif opt == 'big':
        a.append("".join(choice(chars) for x in range(32)))
    elif opt == 'medium':
        # add two digits
        a.extend("".join(choice(string.digits) for x in range(2)))
        # add two punc
        a.extend("".join(choice(punc) for x in range(2)))
        # add 4 letters
        a.extend("".join(choice(string.ascii_letters) for x in range(3)))
        shuffle(a)
        a = choice(string.ascii_letters) + "".join(a)
    else:
        print 'medium pass, or specify big or small'
        return make_password('medium')
    return choice(string.ascii_letters) + "".join(a)

print make_password(sys.argv[1] if sys.argv[1:] else 'medium')
