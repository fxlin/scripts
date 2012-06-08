#!/bin/sh

set -e

for THREAD in InputReader InputDispatcher 
do
    line=`adb shell /system/bin/ps -p -t | grep ${THREAD}`
    tid=`echo ${line} | awk '{print $2}'`
    pid=`echo ${line} | awk '{print $3}'`

    echo ${THREAD} pid: ${pid} tid: ${tid}
    #adb shell cat /proc/${pid}/task/${tid}/stat

    #probably too brief, old?
    #adb shell cat /proc/${pid}/task/${tid}/schedstat

    OUTFILE=/tmp/${pid}-${tid}-sched-stat.txt

    adb shell cat /proc/${pid}/task/${tid}/sched > ${OUTFILE}

    ./sched.py ${OUTFILE}
done
