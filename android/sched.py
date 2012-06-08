#!/usr/bin/env python

import sys

f=file(sys.argv[1], "r")
lines=f.readlines()

for line in lines:
    if line.find("se.statistics") == -1:
        continue
    # now process all sched stat lines
    if line.find("se.statistics.wait_sum") != -1:
        tokens=line.split(":")
        wait_sum=float(tokens[1])
    elif line.find("se.statistics.wait_count") != -1:
        tokens=line.split(":")
        wait_count=int(tokens[1])
    elif line.find("se.statistics.wait_max") != -1:
        tokens=line.split(":")
        wait_max=float(tokens[1])


print "wait: avg %.2f  max %.2f sum %.2f  count %d" %(wait_sum/wait_count, wait_max, wait_sum, wait_count)

