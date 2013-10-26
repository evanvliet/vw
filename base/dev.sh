#!/bin/bash
# +
# Development functions. These are rather old, but serve as
# examples of what might be convenient.
# -
mk() { make $* &> make.log & } # run make in background
tm() { cat make.log ; } # cat make.log
