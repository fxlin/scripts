#!/bin/sh
# build an ICS .so lib and put it to the phone
#
# tested on maguro + ICS
#
# $1 - the name of the .so file, relative to the aosp tree root
# e.g. out/target/product/generic/system/lib/libgui.so
#
# change: separate the building process
#

source color.sh

#set -v
set -e

if [ -z "$1" ]
then 
    echo "which .so to update?, e.g., out/target/product/generic/system/lib/libgui.so"
    exit 1
fi

#PRODUCT=maguro
PRODUCT=generic

SRC_LIBFILE=$1                                       # the name of the .so file, relative to the aosp tree root
AOSP_OUTPATH="out/target/product/${PRODUCT}"         # the output path in aosp tree
DEST_LIBFILE=`echo ${SRC_LIBFILE#${AOSP_OUTPATH}}`   # the abs path+filename on phone

AOSP_ROOT=/home/xzl/android-ICS/

echo -e installing ${bold_white} ${AOSP_ROOT}/${SRC_LIBFILE} ${text_reset} to phone ${bold_white} ${DEST_LIBFILE} ${text_reset}...

# put phone /system to r/w
#
##adb shell /data/local/remount-maguro.sh
adb remount

# upload the compiled lib
adb push ${AOSP_ROOT}/${SRC_LIBFILE} ${DEST_LIBFILE}

# cmp their md5sum
s1=`md5sum ${AOSP_ROOT}/${SRC_LIBFILE} | awk '{print $1}'`
s2=`adb shell busybox md5sum ${DEST_LIBFILE} | awk '{print $1}'`

if [ "$s1" = "$s2" ]
then
    echo -e ${OK} "md5sum check ok"
else
    echo -e $s1, $s2, ${ERROR}, "md5sum check failed"
    exit 1
fi	
