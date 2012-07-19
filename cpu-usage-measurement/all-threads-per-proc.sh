#!/sbin/sh

#
# to get cpu usage of all tasks (threads) within the same process, by 
# dumping /proc/$pid/task/*/stat
#
# should use a python script for post processing

PID=$1

while :
do
    ALL_TASK_DIR=/proc/$PID/task/*

    for dir in $ALL_TASK_DIR
    do 
        #echo -n "$(($(date +%s%N)/1000000)) `cat $dir/stat` \r"
        #echo -n "$(($(date +%s)*1000)) `cat $dir/stat` "
        #echo -n "`date +%s` `cat $dir/stat` "
        echo -n "`./gettimeofday_ms` `cat $dir/stat` "
        echo
    done

    #sleep 1
    usleep 500000
done
