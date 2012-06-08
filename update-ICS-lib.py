#!/usr/bin/env python

import sys
import os
import re
import os.path
import subprocess
import colorama
from colorama import Fore, Back, Style

#
# return true if ret status == 0
# return false otherwise
#

def call_verbose(mycmd):
    # copied from http://docs.python.org/library/subprocess.html#subprocess-replacements
    try:
        retcode = subprocess.call(mycmd, shell=True)
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
            return False
        elif retcode > 0:
            print >>sys.stderr, "Child returned", retcode
            return false
        elif retcode == 0: 
            return True
    except OSError, e:
        print >>sys.stderr, "Execution failed:", e
        return false

def call_must_return_zero(mycmd):
    if not call_verbose(mycmd):
        sys.exit(1)

##################################################################################

## {{{ http://code.activestate.com/recipes/266486/ (r1)
#!/usr/bin/env python

## md5hash
##
## 2004-01-30
##
## Nick Vargish
##
## Simple md5 hash utility for generating md5 checksums of files. 
##
## usage: md5hash <filename> [..]
##
## Use '-' as filename to sum standard input.

import md5
import sys

def sumfile(fobj):
    '''Returns an md5 hash for an object with read() method.'''
    m = md5.new()
    while True:
        d = fobj.read(8096)
        if not d:
            break
        m.update(d)
    return m.hexdigest()


def md5sum(fname):
    '''Returns an md5 hash for file fname, or stdin if fname is "-".'''
    if fname == '-':
        ret = sumfile(sys.stdin)
    else:
        try:
            f = file(fname, 'rb')
        except:
            return 'Failed to open file'
        ret = sumfile(f)
        f.close()
    return ret

def felix_init():
    colorama.init()    
##################################################################################################


if (len(sys.argv) <= 1):
    print "which .so to update?, e.g., out/target/product/generic/system/lib/libgui.so"
    sys.exit(1)

PRODUCT="generic"

if "TARGET_PRODUCT" in os.environ:
    target_product = os.environ["TARGET_PRODUCT"]
    if target_product.find("maguro") != -1:
        PRODUCT = 'maguro'
    elif target_product.find("tuna") != -1:
        PRODUCT = 'tuna'
    # XXX more product here
    else:
        print target_product
else:
    print "TARGET_PRODUCT not set. try aosp: source build/envsetup.sh and lunch 8"
    sys.exit(1)


SRC_LIBFILE=sys.argv[1]

# the relative output path in aosp tree
AOSP_OUTPATH='out/target/product/' + PRODUCT

# DEST_LIBFILE: the abs path+filename on phone
if not SRC_LIBFILE.startswith(AOSP_OUTPATH):
    print SRC_LIBFILE, AOSP_OUTPATH
    sys.exit(1)
else:
    DEST_LIBFILE=SRC_LIBFILE[len(AOSP_OUTPATH):]

if "ANDROID_BUILD_TOP" not in os.environ:
    print "ANDROID_BUILD_TOP not set. try aosp: source build/envsetup.sh and lunch 8"
    sys.exit(1)
else:
    AOSP_ROOT = os.environ["ANDROID_BUILD_TOP"]


print "installing " + Style.BRIGHT + os.path.join(AOSP_ROOT, SRC_LIBFILE) + Style.RESET_ALL \
                   + " to phone " \
                  + Style.BRIGHT + DEST_LIBFILE + Style.RESET_ALL + " ..."

call_must_return_zero("adb remount")
call_must_return_zero("adb push " + os.path.join(AOSP_ROOT, SRC_LIBFILE) + " " + DEST_LIBFILE)

s1 = md5sum(os.path.join(AOSP_ROOT, SRC_LIBFILE))
call_must_return_zero("adb pull " + DEST_LIBFILE + " /tmp/dest_libfile")
s2 = md5sum("/tmp/dest_libfile")

if (s1 == s2):
    print Fore.GREEN + "md5sum check ok" + Fore.RESET
else:
    print "md5sum check failed"
    sys.exit(1)

