#!/usr/bin/env python

'''
to post process the output of 'perf sched map'
for per task statistics

assume map.txt is the output of `perf sched map`

usage: ./perf-map.py map.txt

'''

import sys

f=file(sys.argv[1])
lines=f.readlines()

task_ids={}
task_sched_counts={}

for line in lines:
    tokens=line.split()
    #print tokens
    if len(tokens) == 3:  # a sched activity from known task
        task_sym=tokens[0][1:]
        if task_sym == ".": # an idle CPU..
            continue
        else:
            task_sched_counts[task_sym] += 1
    else:                 # new task
        task_sym=tokens[3]
        task_name=tokens[5]
        task_id=task_name.split(":")[-1]

        task_sched_counts[task_sym] = 1
        #task_ids[task_sym]=task_id
        task_ids[task_sym]=task_name

for key, value in sorted(task_sched_counts.iteritems(), key=lambda (k,v): (v,k), reverse=True):
        print "%s: %s" % (key, value),
        print "%s " %(task_ids[key])


