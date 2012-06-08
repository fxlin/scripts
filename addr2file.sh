#!/bin/sh
#
# Map kernel addresses to their source file names
#
# $1: the input file from systemtap or oprofile. each line is
#
#   addr count
#
# output - a list of source file names, each corresponding to a fun name (symbol)
#
# Note: don't user kernel symbols (e.g. func names) - ambiguous; instead, use kernel vma
#

#KERNEL=/home/xzl/android-galaxymaguro/kernel
KERNEL=~/android-galaxys2/samsung-kernel-galaxysii/
CROSS_COMPILE=arm-eabi-

set -e
#set +v

[ -f ${KERNEL}/System.map ] || { echo "System.map no found"; exit 1; }

while read line; do
    ADDR=`echo $line | awk '{print $1}'`
    COUNT=`echo $line | awk '{print $2}'`
    FILE=`${CROSS_COMPILE}addr2line ${ADDR} -e ${KERNEL}/vmlinux`
    echo "$FILE $COUNT"    
done < $1
