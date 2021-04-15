#!/usr/bin/python
from sys import argv

iname = argv[1]
oname1 = argv[2]
oname2 = argv[3]

with open(iname) as fin:
    idata = fin.readlines()

    write1 = True
    write2 = False
    with open(oname1, 'w') as f1:
        with open(oname2, 'w') as f2:
            for l in idata:
                if "read_restart" in l:
                    write1 = False
                    write2 = True
                if write1:
                    f1.write(l)
                if write2 and "read_restart" not in l and "reset_timestep" not in l:
                    f2.write(l)

