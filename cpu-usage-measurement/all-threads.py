#!/usr/bin/env python

import sys
import re

field_list = [
  "ts_ms",      # add by xzl
  "pid",
  "tcomm",
  "state",
  "ppid",
  "pgid",
  "sid",
  "tty_nr",
  "tty_pgrp",
  "flags",
  "min_flt",
  "cmin_flt",
  "maj_flt",
  "cmaj_flt",
  "utime",
  "stimev",
  "cutime",
  "cstime",
  "priority",
  "nicev",
  "num_threads",
  "it_real_value",
  "start_time",
  "vsize",
  "rss",
  "rsslim",
  "start_code",
  "end_code",
  "start_stack",
  "esp",
  "eip",
  "pending",
  "blocked",
  "sigign",
  "sigcatch",
  "wchan",
  "zero1",
  "zero2",
  "exit_signal",
  "cpu",
  "rt_priority",
  "policy",
]

def repl(matchobj):
    return matchobj.group(1).replace(" ","")
    #return matchobj.group(1) + matchobj.group(2)

def strip_space_in_parenthesis(line):
    #ex1=r'''(\(\S*)\s*(\S*\))'''
    ex1=r'''(\(.*\))'''    
    res = re.sub(ex1, repl, line)
    return res

# filter 'error' lines
def is_valid_line(line):
    ex1=re.compile(r'''(\(.*\))''')    
    res = ex1.search(line)
    if res == None:
        return False
    else:
        return True
    
def split_line(line):
    res_dict = {}
    line = strip_space_in_parenthesis(line)
    tokens = line.split()
    for i in range(0, len(field_list)):
        try:
            res_dict[field_list[i]] = tokens[i]
        except:
            print "error --- " + line
                        
    return res_dict                    

'''
testline = "1342196614 13586 (Thread 1564 aaa) S 1889 1889 0 0 -1 4194368 2 0 0 0 0 0 0 0 20 0 62 0 3190671 366927872 17006 4294967295 32768 37264 3203124128 1429408360 1074721716 0 4612 4 38120 3232809536 0 0 -1 0 0 0 0 0 0 "         
tokens = split_line(testline)
print tokens
'''

all_records = {}        # key: thread-id, value: a list of 'records', where each record is a dict, read from a log line

if __name__ == "__main__":    
    f=file(sys.argv[1])
    lines = f.readlines()
    for line in lines:
        if not is_valid_line(line):
            continue                
        rec = split_line(line)
        if not rec["pid"] in all_records:
            all_records[rec["pid"]] = []                
        all_records[rec["pid"]].append(rec)

for pid, rec_list in all_records.iteritems():
    print "%s %d records " %(pid, len(rec_list)),
    for i in range(1, len(rec_list)):
        #print rec_list[i]["utime"]
        print float(rec_list[i]["utime"]) - float(rec_list[i-1]["utime"]),              
    print
    
# for testing   
#print strip_space_in_parenthesis("(hello world)")
    
