#!/bin/sh
#
# Given a kernel symbol name, find out its source file location
#
# $1: the input file from systemtap. each line is a ker func count
#
#   sym count
#
# output - a list of source file names, each corresponding to a fun name (symbol)
#

KERNEL=/home/xzl/android-galaxymaguro/kernel
CROSS_COMPILE=arm-eabi-

set -e
#set +v

[ -f ${KERNEL}/System.map ] || { echo "System.map no found"; exit 1; }

while read line; do
    SYM=`echo $line | awk '{print $1}'`
    COUNT=`echo $line | awk '{print $2}'`
    #echo $SYM
    ADDR=`grep -w $SYM ${KERNEL}/System.map | awk '{print $1}'`
    #echo $ADDR
    FILE=`${CROSS_COMPILE}addr2line ${ADDR} -e ${KERNEL}/vmlinux`
    echo "$FILE $COUNT $SYM"
done < $1
