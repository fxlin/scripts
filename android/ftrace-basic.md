#!/bin/sh

#
#  test uptime-xzl clock (true uptime) by tracing
#  sched events. 
#

### -- on the device ---
echo 0 > /sys/kernel/debug/tracing/tracing_on
echo "" > /sys/kernel/debug/tracing/trace

# select the clock
echo uptime-xzl > /sys/kernel/debug/tracing/trace_clock
cat /sys/kernel/debug/tracing/trace_clock
# check: proper clock should be selected

echo 16384 > /sys/kernel/debug/tracing/buffer_size_kb
echo 1 > /sys/kernel/debug/tracing/events/sched/enable

# binder?
echo 1 > /sys/kernel/debug/tracing/events/binder/binder_transaction/enable
echo 1 > /sys/kernel/debug/tracing/events/binder/binder_transaction_received/enable

echo 1 > /sys/kernel/debug/tracing/tracing_on

# ... can unplug ...
sleep 10
# ... plug  ...

echo 0 > /sys/kernel/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace > /sdcard/sched.txt

### -- on host ---
cd /tmp/
adb pull /sdcard/sched.txt
head sched.txt -n 30
tail sched.txt -n 30

