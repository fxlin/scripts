#!/usr/bin/env python

import errno, optparse, os, select, subprocess, sys, time, zlib

'''
We assume that in the trace file, each "update" of top begins with 
a header line, as examplified:
PID PR CPU% S  #THR     VSS     RSS PCY UID      Name

followed by data lines, such as:
683  0   5% S   121 1699088K 107880K  fg system   system_server

We ignore lines for system-wide statistics such as 
User 16%, System 9%, IOW 0%, IRQ 0%
User 47 + Nice 0 + Sys 28 + Idle 218 + IOW 0 + IRQ 0 + SIRQ 0 = 293

We ignore comments lines being with "# "

Data structures:

updates is a list, each of which is one 'update' of top output,
update[i] is a list of data items, as exemplified below
{'PR': '0', 'VSS': '0K', 'UID': 'root', '#THR': '1', 'PID': '14295', 'S': 'S', 'PCY': '??', 'Name': 'kworker/u:3', 'CPU%': '0%', 'RSS': '0K'}
{'PR': '0', 'VSS': '0K', 'UID': 'root', '#THR': '1', 'PID': '6155', 'S': 'S', 'PCY': '??', 'Name': 'kworker/u:1', 'CPU%': '0%', 'RSS': '0K'}
{'PR': '0', 'VSS': '0K', 'UID': 'root', '#THR': '1', 'PID': '14775', 'S': 'S', 'PCY': '??', 'Name': 'kworker/0:2H', 'CPU%': '0%', 'RSS': '0K'}
'''

header_line = None
header = []
updates = []

def build_header(tokens):
  global header
  header = tokens	# just save it 

'''
The PCY field {fg|bg} is not always visible in each data line. 
We create a fake token if PCY is missing, so that each data line has the same
number of fields
'''
def fix_data_PCY(tokens):
  global header
  assert header != []
  idx = header.index('PCY')  # error if no such an item
  #print tokens[idx]
  if tokens[idx] == "bg" or tokens[idx] == "fg":
    return
  else:
    tokens.insert(idx, "??")


def parse(trace_fname):
  global header_line
  global header
  global updates

  f=file(trace_fname)
  lines=f.readlines()
  for line in lines:
    tokens=line.split()
    #print tokens
    if len(tokens) == 0 or tokens[0] == "User" or tokens[0] == "#":
      pass
    elif tokens[0] == "PID": # we encounter a header line; start a new update
      if header_line == None:
        build_header(tokens)
        header_line = line
      else: # we saw a header line before, compare
        assert cmp(line, header_line) == 0
      updates.append([])	# append a new update
    else: # we encounter a data line, parse it to a dictionary
      assert header_line != None
      fix_data_PCY(tokens)
      d = {}
      if len(header) != len(tokens):
        #print header_line
        #print tokens
        assert False
      for idx, h in enumerate(header):
        d[h] = tokens[idx]
      updates[-1].append(d)
      #print d
  
  # print some statistics
  print "parsing done. %d updates found" %(len(updates))
  
  # debugging
'''
  for u in updates:
    for d in u:
      print d 
'''

''' 
Now we have updates parsed. 
Figure out which tasks have ever consumed a notable portion of CPU time, in 
any update.

XXX: add top 5 tasks regardless of their cpu%?
'''
notable_tasks = []

def get_notable_tasks():
  global updates
  global notable_tasks
  
  assert updates != []
  
  for u in updates:
    for d in u:
      cpu = int(d['CPU%'][:-1]) # have to strip the % symbol
      if cpu >= 5:  # 5%
        task = (d['Name'], d['PID'])
        if not task in notable_tasks:
          notable_tasks.append(task)


'''
Each item correponds to an update. Each item is a dict:
(name, pid)->cpu
'''
notable_tasks_cpu = []

def get_notable_tasks_cpu():
  global updates
  global notable_tasks
  global notable_tasks_cpu
  
  assert updates != []
  assert notable_tasks != []
  
  for u in updates:
    this_update_cpu = {}
    
    for d in u:
      cpu = int(d['CPU%'][:-1]) # have to strip the % symbol
      task = (d['Name'], d['PID'])
      
      if task in notable_tasks:
          assert (not this_update_cpu.has_key(task))
          this_update_cpu[task] = cpu
    
    notable_tasks_cpu.append(this_update_cpu)


def output_notable_tasks_cpu():
  global notable_tasks
  global notable_tasks_cpu
  
  assert notable_tasks != []
  assert notable_tasks_cpu != []
  
  fname = 'top.data'  
  f = open(fname, 'w')
  
  # print header. 
  print >> f, -999,  # a dummy column header for col 1
  for (n, p) in notable_tasks:
    print >> f, "%s-%s" %(n, p),
    #print >> f, "%s" %(p),
    #f.write(",%s" %(p))
  print >> f
  
  for uidx, u in enumerate(notable_tasks_cpu):
    # we iterate notable_tasks (which is a dict) hoping that the iteration order
    # will be the same as in the header printing above.
    print >> f, uidx, 
    for (n, p) in notable_tasks:
      if (n, p) in u: 
        #print n, p, u[(n,p)]
        print >> f, u[(n,p)],
      else:
        print >> f, 0,	  # this is possible: the task was gone or was not created yet.
    print >> f
    
  print >> sys.stderr, "Wrote data file: %s" %fname


# Stacked graph idea:
# https://newspaint.wordpress.com/2013/09/11/creating-a-filled-stack-graph-in-gnuplot/
# this requires gnuplot >=4.6 for sum()
# return a string. 
def _gen_gnuplot_script():
  global notable_tasks
  assert notable_tasks != []
  
  ntasks = len(notable_tasks)
  
  header='''
# Automatically generated. Don't edit. 
# NOTE: require gnuplot >=4.6
#
set title "CPU usage of top processes"
set datafile separator " "
#set terminal x11
set terminal png size 480,400 enhanced truecolor font 'Verdana,9'
set output "top.png"
set yrange [0:100]
set ylabel "CPU"
set xlabel "Sample"
set pointsize 0.8
set border 11
set xtics out
set tics front
set key below
'''
  header += "plot \\\n"
  header += "  for [i=2:%d:1] \\\n" %(ntasks+1)
  header += "    \"top.data\" using 1:(sum [col=i:%d] column(col)) \\\n" %(ntasks+1)
  header += "        title columnheader(i) \\\n"
  header += "        with filledcurves x1 \n"

  return header

def gen_gnuplot_script():
  gscript_fname = "top.plot"
  gscript=open(gscript_fname, "w")
  gscript.write(_gen_gnuplot_script())
  gscript.close()
  print >> sys.stderr, 'Wrote gnuplot script: %s' %gscript_fname

if __name__ == '__main__':
  #capture()
  parse("./top.trace")
  get_notable_tasks()
  #print notable_tasks
  get_notable_tasks_cpu()
  output_notable_tasks_cpu()
  gen_gnuplot_script()
