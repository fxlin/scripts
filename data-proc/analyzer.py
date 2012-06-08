#!/usr/bin/env python

import sys

NUM_CHANNELS=16
last_value = [-1]*NUM_CHANNELS
last_ts = [-1.0]*NUM_CHANNELS   # last event happen timestamp
once = 1

filters=[
"//Sieve out the display of the data",
"----------------------------------------------------",
"The style of the Data's display of Bus is Hexadecimal",
"Bar position",
"Channel name"
]
filtered = 0

f=file(sys.argv[1])
lines=f.readlines()

for line in lines:

    # filter garbage lines --- stupid analyzer program!
    to_exclude = 0
    for fi in filters:    
        #print fi, line, line.find(fi)
        if line.find(fi) != -1:
            to_exclude = 1
            filtered += 1
            break
    if to_exclude:
        #print "----", line,
        continue

    tokens=line.split()
    # timestamp -- in us
    ts_s = tokens[0]
    if ts_s[-2:] == 'ns':        
        ts=float(ts_s[0:-2])*0.001
    elif ts_s[-2:] == 'ms':        
        ts=float(ts_s[0:-2])*1000
    elif ts_s[-2:] == 'us':        
        ts=float(ts_s[0:-2])
    else:
        print "ts unit error", line
        sys.exit(1)

    if once:
        last_value = tokens[1:]
        last_ts = [ts]*NUM_CHANNELS
        once = 0
        continue    

    this_value = tokens[1:]

    #print last_value, this_value

    for i in range(0, len(this_value)):
        if last_value[i] == '0' and this_value[i] == '1':
            print "%.4f ch %d up" %(ts, i),
            print "low-level duration %.4f" %(ts - last_ts[i])
            last_ts[i] = ts
        elif last_value[i] == '1' and this_value[i] == '0':        
            print "%.4f ch %d down" %(ts, i),
            print "high-level duration %.4f" %(ts - last_ts[i])
            last_ts[i] = ts     
    last_value = this_value

print 'done, filtered %d lines' %filtered
