#!/bin/sh
#
# input - System.map from kernel build
# output - append the source file info to each line of System.map
#

#KERNEL=/home/xzl/android-galaxymaguro/kernel
KERNEL=/home/xzl/android-galaxys2/siyah-kernel-ICS/siyahkernel3

#CROSS_COMPILE=arm-eabi-

# for linaro gcc-4.6
CROSS_COMPILE=arm-linux-gnueabi-

set -e
#set +v

[ -f ${KERNEL}/System.map ] || { echo "System.map no found"; exit 1; }

while read line; do
    ADDR=`echo $line | awk '{print $1}'`
    SYM=`echo $line | awk '{print $3}'`
    #COUNT=`echo $line | awk '{print $2}'`
    #echo $SYM
    #ADDR=`grep -w $SYM ${KERNEL}/System.map | awk '{print $1}'`
    #echo $ADDR
    FILE=`${CROSS_COMPILE}addr2line ${ADDR} -e ${KERNEL}/vmlinux`
    echo "$ADDR $SYM $FILE"
done < ${KERNEL}/System.map
