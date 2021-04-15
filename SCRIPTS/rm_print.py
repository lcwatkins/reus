#!/usr/bin/python
from sys import argv

iname = argv[1]
oname = argv[2]
key   = argv[3]
with open(iname) as f:
    data = f.readlines()

is_print = False
with open(oname, 'w') as f:
    for l in data:
        if "PRINT ..." in l:
            is_print = True
        if not is_print and key not in l:
            f.write(l)
        elif "... PRINT" in l:
            is_print = False
    assert(not is_print)
    
