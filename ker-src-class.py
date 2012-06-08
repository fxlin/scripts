#!/usr/bin/env python

import sys

# ker_path to match against src files

#ker_prefix = "/home/xzl/android-galaxymaguro/kernel/"
ker_prefix="/home/xzl/android-galaxys2/samsung-kernel-galaxysii/"

ker_paths = [
    "drivers/",
        "drivers/gpu/",
        "drivers/net/",
        "drivers/video/",
        "drivers/media/",
        "drivers/usb/",
        "drivers/base/",
        "drivers/staging/android/",
    "kernel/",
            "kernel/timer.c",            
            "kernel/softirq.c",
            "kernel/sched.c",
            "kernel/futex.c",
    "mm/",
    "arch/arm/",
        "arch/arm/oprofile/",
        "arch/arm/mach-s5pv310/cpuidle.c",
    "fs/",
    "net/",
]

for i in (range(0, len(ker_paths))):
    p = ker_paths[i]
    ker_paths[i] = ker_prefix + p

src_counts = {}

total = 0

f=file(sys.argv[1])
lines=f.readlines()
for line in lines:
    tokens = line.split()
    #print tokens
    src, loc = tokens[0].split(":")    
    count = int(tokens[1])
    total += count
    if not src_counts.has_key(src):
        src_counts[src] = count
    else:
        src_counts[src] += count


#for src, count in src_counts.iteritems():
#    print src, count

print "total", total

for kp in ker_paths:
    hit=0
    for src, count in src_counts.iteritems():
        if src.startswith(kp):
            hit+=count
    print kp, "%", "%.2f" %(hit*100.0/total)
