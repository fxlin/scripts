#!/usr/bin/env python

""" 
dump the statistics of scheduling info from systrace

Usage:
{prog} out.html start_time end_time
"""

import errno, optparse, os, select, subprocess, sys, time, zlib
import operator
import re

keyword="sched_switch"
total = 0
all_procs = {}

'''
Assumption of the trace format: 

the interesting line will look like:

sdcard-195   (  185) [000] d..3   131.418750: sched_switch: prev_comm=sdcard prev_pid=195 prev_prio=120 prev_state=D ==> next_comm=mmcqd/0 next_pid=127 next_prio=120
<idle>-0     (-----) [000] d..3   121.309424: sched_switch: prev_comm=swapper/0 prev_pid=0 prev_prio=120 prev_state=R ==> next_comm=id.wearable.app next_pid=781 next_prio=120\n\
 Heap thread poo-609   (  601) [000] d..3   131.367734: sched_switch: prev_comm=Heap thread poo prev_pid=609 prev_prio=120 prev_state=S ==> next_comm=hwcVsyncThread next_pid=198 next_prio=111\n\

test this line and the following regex on:
http://pythex.org/
'''

lineregex=r'''\s*(.+)\s+\(\s*(\S+)\)\s*\[\d+\]\s*\S*\s*(\d+\.\d+):\s*sched_switch:\s*prev_comm=(.+)\s*prev_pid=(\d+)\s*prev_prio=(\d+)\s*prev_state=(\S+)\s*==>\s*next_comm=(.+)\s*next_pid=(\d+)\s*next_prio=(\d+)'''

'''
return None if bad
'''
def get_timestamp(line):
  # first extract the time stamp
  t0=line.split(')')
  if len(t0) < 2:
    return None
    
  
  t1 = t0[1].split(':')
  if len(t1) < 2:
    return None
        
  t2 = t1[0].split(' ')
  if len(t2) < 2:
    return None
  
  timestamp=t2[-1]
  ts = float(timestamp)
  return ts

'''
return (prev_tid, prev_pid, prev_comm, next_comm, next_tid)
'''
def get_tasks(line):
    # we must be careful as comm (process name) may contain spaces
    
    # get prev comm and pid
    tokens=line.split('(')
    if len(tokens) <= 1:
      return None
     
     
    tokens=line.split(keyword)
    if len(tokens) <= 1:
      return None

    s = tokens[1]
    tokens = s.split("next_comm=")
    assert tokens > 1
    
    s = tokens[1]
    tokens = s.split("next_comm=")
    assert tokens > 1
        
    s = tokens[1]
    tokens = s.split("next_comm=")
    assert tokens > 1
    
    
    s = tokens[1]
    tokens = s.split("next_comm=")
    assert tokens > 1
    
    s = tokens[1]
    tokens = s.split(" next_pid=")
    assert tokens > 1
    comm = tokens[0]
    
    s = tokens[1]
    tokens = s.split(" next_prio=")
    assert tokens > 1
    pid = tokens[0]

'''
return (timestamp, prev_tid, prev_pid, prev_comm, next_comm, next_tid)
'''
def parseline(line):
  m = re.match(lineregex, line)
  if not m:
    return None
  else:
    return (m.group(3), m.group(5), m.group(2), m.group(1), m.group(8), m.group(9))

once = True

begin_ts = 0
end_ts = 0
begin_window_ts = -1
end_window_ts = -1
last_ts = 0
last_suspend = 0
last_resume = 0
last_resume_fix = -1  # resume, after clock rollback

last_tid = -1

# key: pid, value: a dict of {key: tid, value: cputime, sched_cnt}
all_pids={}

# for sanity check. key: tid, value: (pid, comm)
all_tids={}

def statistics():
  global all_pids, all_tids
  
  for (pid, d) in all_pids.iteritems():
    pid_sched = 0
    pid_t = 0.0
    
    print "pid:", pid
    
    for tid, s in d.iteritems():
      # s is an array of all time slices
      #print s
      tid_sched = len(s)
      tid_t = sum(s)
      
      pid_sched += tid_sched
      pid_t += tid_t
      
      print "     tid: %s %s time: %.6f sched: %d" %(tid, all_tids[tid][1], tid_t, tid_sched)
      
    print "total: time: %.6f sched: %d" %(pid_t, pid_sched)
    print
  
  
# the time range we are interested, in sec.
min_t = 0.0
max_t = float("inf")

if __name__ == '__main__':
  f=file(sys.argv[1])
  lines=f.readlines()
  
  if len(sys.argv) > 2:
    min_t = float(sys.argv[2])
    max_t = float(sys.argv[3])
  
  inheader = True
  nlines = len(lines)
  
  i = 0
  badlines=0
  
  while i < nlines:
    line = lines[i]
    
    # we are skipping the header
    if inheader:
      if line.find("CPU") != -1 and line.find("TIMESTAMP") != -1 and line.find("FUNCTION") != -1:
        inheader = False
        i += 2
        print "		skipped header (%d lines)..." %(i)
      else:
        i += 1
      continue
    
    # we must be careful as comm (process name) may contain spaces
    # we are parsing the body 
    i += 1
    
    if line.find(keyword) == -1:
      continue
      
    res = parseline(line)
    if res == None:
      print "bad line"
      print line
      badlines += 1
    else:
      #print res
      (timestamp, prev_tid, prev_pid, prev_comm, next_comm, next_tid) = res
      #print prev_tid, "->", next_tid
      
      ts = float(timestamp)
      if ts < min_t:   # XXX improve this. 
        continue
      elif begin_window_ts < 0: 
        begin_window_ts = ts
        print "---- update begin --- ", ts
        
      if ts > max_t:
        if end_window_ts < 0:
          end_window_ts = ts
          print "---- update end --- ", ts
        continue
        


      if not once:
        # sanity check
        if last_tid != prev_tid:
          print "bad last_tid:", last_tid
          continue
        
        # we finish a timeslice for prev_tid, record.
        t = ts - last_ts
        
        if t > 1:
          print "--- BUG?! last_ts %.6f t = %.6f--- line %d" %(last_ts, t, i)
        
        # manual fix the pid: if equals "-----", this means pid == tid
        if prev_pid == "-----":
          prev_pid = prev_tid
          
        # first time see the pid
        if not prev_pid in all_pids:
          all_pids[prev_pid] = {}
        d = all_pids[prev_pid]
        # first time see the tid
        if not prev_tid in d:
          d[prev_tid] = []
        # record the time slice 
        # add XXX more info?
        d[prev_tid].append(t)
        
        # sanity check
        if not prev_tid in all_tids:
          all_tids[prev_tid] = (prev_pid, prev_comm)
        if all_tids[prev_tid][0] != prev_pid:
          print "--- BUG --- !"
      else:
        begin_ts = ts
        once = False
      
      last_ts = ts
      last_tid = next_tid
  
  statistics()
  print "total elapsed %.6f" %(ts - begin_ts)
  print "window  %.6f" %(end_window_ts - begin_window_ts)
