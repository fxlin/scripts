#!/usr/bin/env python

import sys

if __name__ == "__main__":
    f = file(sys.argv[1])
    lines = f.readlines()
    for line in lines:
        tokens=line.split()
        for t in tokens:
            print t, ",",
        print


