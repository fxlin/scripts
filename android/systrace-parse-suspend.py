#!/usr/bin/env python

""" 
parse the sched events from systrace html output (which is captured by atrace on Android). 
output sched statistics. e.g, how many tasks, how many ctx switches.

Usage:
{prog} out.html
"""

import errno, optparse, os, select, subprocess, sys, time, zlib
import operator

keyword="machine_suspend[3]"
total = 0
all_procs = {}

'''
Assumption of the trace format: 

the interesting line will look like:
(some process info...) sched_switch: prev_comm=su prev_pid=6975 prev_prio=120 prev_state=S ==> next_comm=daemonsu next_pid=6978 next_prio=120
'''

once = True

begin_ts = 0
end_ts = 0
last_ts = 0
last_suspend = 0
last_resume = 0
last_resume_fix = 0  # resume, after clock rollback

if __name__ == '__main__':
  f=file(sys.argv[1])
  lines=f.readlines()
  
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
    
    # first extract the time stamp
    t0=line.split(')')
    if len(t0) < 2:
      #print "bad line"
      #print t0
      badlines += 1
      continue
    
    t1 = t0[1].split(':')
    if len(t1) < 2:
      print "bad line"
      print t1
      continue
          
    t2 = t1[0].split(' ')
    if len(t2) < 2:
      print "bad line"
      print t1
      continue    
    
    timestamp=t2[-1]
    ts = float(timestamp)
    
    if once:
      once = False
      begin_ts = ts
    else:
      if ts - last_ts < 0:
        print "		[%d] clock roll back: at %.6f last_resume %.6f we lose %.6f" %(i, last_ts, last_resume, last_ts - last_resume)
        last_resume_fix = ts
    
    last_ts = ts
    
    #print timestamp
    
    t = line.split(keyword)
    if len(t) <= 1:
      continue
    elif t[1].find("begin") != -1:
      print "[%d]suspends. online for %.6f (%.6f -- %.6f)" %(i, ts - last_resume_fix, last_resume_fix, ts)
      last_suspend = ts
    elif t[1].find("end") != -1:
      print "[%d]resumes. offline for %.6f (%.6f -- %.6f)" %(i, ts - last_suspend, last_suspend, ts)
      last_resume = ts
    else:
      print "??? cannot understand line" + line
      
    
  print "total: %.6f -- %.6f" %(begin_ts, ts)
      
