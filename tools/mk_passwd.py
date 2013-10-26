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
    if opt == 'small':  # short string wih limited puntuation
        a.extend("".join(choice(pibm) for x in range(2)))
        a.extend("".join(choice(string.digits) for x in range(2)))
        a.extend("".join(choice(chars) for x in range(5)))
    elif opt == 'big':  # long string of letters and numbers
        a.append("".join(choice(chars) for x in range(20)))
    elif opt == 'medium':  # two digits two punc and six letters
        a.extend("".join(choice(string.digits) for x in range(2)))
        a.extend("".join(choice(punc) for x in range(2)))
        a.extend("".join(choice(string.ascii_letters) for x in range(6)))
    else:
        print 'medium pass, or specify big or small'
        return make_password('medium')
    # make first char a letter and shuffle rest
    shuffle(a)
    return choice(string.ascii_letters) + "".join(a)

print make_password(sys.argv[1] if sys.argv[1:] else 'medium')
