#!/usr/bin/env python

import sys

'''
given kernel symbols in perf report output, output statistics of kernel source files

 $1 - output of systemmap2file.sh
 $2 - output of perf report 
 
 use case
 
./perf-sym2file.py s2/pandora-playing-300sec.txt
 
'''

SYSMAP = "s2/sysmap"
    
# read the 'enhanced system.map' with source location, which is the output of systemmap2file.sh
# create a dict {sym, source}

def load_sysmap(fname):
    sym_dict = {}
    f = file(fname)
    lines = f.readlines()
    for line in lines:
        [addr, sym, src] = line.split()
        sym_dict[sym] = src
    return sym_dict
    
# load perf output
#
# overhead  command
#
# return: {sym, val}  -- same sym accumlated
def load_perf_out(fname):
    total_val = 0.0
    perf_dict = {}
    f = file(fname)
    lines = f.readlines()
    for line in lines:
        try:
            #print line
            #percent=line[5:9]
            #is_ker=line[62:65]        
            #sym=line[66:].split()[0]
            tokens=line.split()
            percent=tokens[0]
            is_ker=tokens[3]
            sym=tokens[4]
            if (is_ker == '[k]'):
                val = float(percent.replace("%",""))
                if (val < 0.01):
                    val = 0.01
                if not sym in perf_dict:
                    perf_dict[sym] = 0                    
                perf_dict[sym] += val
                total_val += val                
                #print sym, val
        except:
            print 'skip line:' + line                
    print "total val %f" %total_val            
    return perf_dict

def total_val(di):
    t = 0.0
    for subsys, val in di.iteritems():                   
        t += val
    return t
    

def src2subsys(src):
    #ker_prefix="/home/xzl/android-galaxys2/samsung-kernel-galaxysii/"
    ker_prefix="/media/vodka/home/xzl/android-galaxys2/siyah-kernel-ICS/siyahkernel3/"
    ker_paths = [
        "drivers/",
#            "drivers/gpu/",
#            "drivers/net/",
#            "drivers/video/",
#            "drivers/media/",
#            "drivers/usb/",
#            "drivers/base/",
#            "drivers/staging/android/",
        "kernel/",
#                "kernel/timer.c",            
#                "kernel/softirq.c",
#                "kernel/sched.c",
#                "kernel/futex.c",
        "mm/",
        "arch/arm/",
 #           "arch/arm/oprofile/",
 #           "arch/arm/mach-s5pv310/cpuidle.c",
        "fs/",
        "net/",
        "lib/",
        "sound/",
        "block/",        
        "security/",
    ]
    
    for i in (range(0, len(ker_paths))):
        p = ker_paths[i]
        ker_paths[i] = ker_prefix + p
    
    for kp in ker_paths:
        if kp in src:
            return kp

    #print src            
    return "[Uncategorized]"        
                
def sym_2_src_manual(sym):
    
    if sym[0:3] == "dhd":
        src = "drivers/net/wireless/bcmdhd/src/dhd/sys/dhd_sdio.c:0"
    elif sym[0:6] == "bcmsdh" or sym in ["pktq_mpeek", "pktq_mlen", "net_os_send_hang_message"]:
        src = "drivers/net/wireless/bcmdhd/src/bcmsdio/sys/bcmsdh.c:0"
    else:
        print "unknown symbol %s" %sym
        src = "unknown"

    return src        
                                
def src_distribution_one(perf_fname):
    sym2src = load_sysmap(SYSMAP)            
    perf = load_perf_out(perf_fname)    

    print total_val(perf)

    subsys_to_percent = {}

    for sym, val in perf.iteritems():
        if sym in sym2src:
            src = sym2src[sym]
        else:
            src = sym_2_src_manual(sym)
            
        subsys = src2subsys(src)                                
        #print sym, src, subsys
        if not subsys in subsys_to_percent:
            subsys_to_percent[subsys] = 0.0
            
        #subsys_to_percent[subsys] += val     ## change this for the cpu percentange
        subsys_to_percent[subsys] += 1
            
    for subsys, val in subsys_to_percent.iteritems():                   
        print subsys, val


def cross_compare_syms_two(perf_fname1, perf_fname2):
    perf1 = load_perf_out(perf_fname1)    
    perf2 = load_perf_out(perf_fname2)    
    sym2src = load_sysmap(SYSMAP)            
    
    subsys_stat = {}
    
    for sym, val in perf1.iteritems():
         if sym in perf2:
            #count += 1
            if sym in sym2src:
                src = sym2src[sym]
            else:
                src = sym_2_src_manual(sym)                    
            subsys = src2subsys(src)
            
            if not subsys in subsys_stat:
                subsys_stat[subsys] = 0
            subsys_stat[subsys] += 1
                                       
    #print count, len(perf1), len(perf2)
    for subsys, val in subsys_stat.iteritems():                   
        print subsys, val


if __name__ == "__main__":
    #src_distribution_one(sys.argv[1])        
    cross_compare_syms_two(sys.argv[1], sys.argv[2])



