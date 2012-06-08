#!/usr/bin/env python
'''
    inspired by cpu.sh

    sample /proc/vmstat to get cpu usage stats.
    to minimize overhead
    - minimize syscalls
    - dont dump the results until finally done


    STOP WORKING ON IT SINCE NO PYTHON ON ANDROID...
'''
import sys
import numpy
import time

header = "USER    NICE    SYS   IDLE   IOWAIT  IRQ  SOFTIRQ  STEAL  GUEST"
N = 180

if (len(sys.argv) > 1):
    N = int(sys.argv[1])



f=file("/proc/stat")
line=f.readline()    # for now only retrieve the 1st line
tokens=line.split()   
if (tokens[0] != 'cpu'):
    print "wrong /proc/stat format?"
    sys.exit(1)
num=len(tokens[1:])
samples=numpy.array([0]*num)
prev_samples=numpy.array([0]*num)

for i in range(1, N):
    f.seek(0)
    line=f.readline()    # for now only retrieve the 1st line
    t=numpy.array(tokens[1:])
    samples=t.astype('L')
    print "smp", samples
    diff_samples = samples-prev_samples
    print "diff", diff_samples             
    prev_samples = samples
    time.sleep(1)
