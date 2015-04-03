#!/bin/sh

# run atrace with usb cable unplugged
# good for capturing c-state and s-state events 
#
# we assume that atrace is modified to use uptime-xzl clock
# 
# XXX: make this a standalone android script
#

adb shell 

# --- on device ----

su

# --- enable w for nonroot --- 
chmod 777 /sys/kernel/debug/tracing/events/power/cpu_idle/enable
chmod 777 /sys/kernel/debug/tracing/events/sched/sched_switch/enable
chmod 777 /sys/kernel/debug/tracing/events/sched/sched_wakeup/enable
chmod 777 /sys/kernel/debug/tracing/options/overwrite
chmod 777 /sys/kernel/debug/tracing/buffer_size_kb
chmod 777 /sys/kernel/debug/tracing/options/print-tgid
chmod 777 /sys/kernel/debug/tracing/tracing_on
chmod 777 /sys/kernel/debug/tracing/trace_clock
chmod 777 /sys/kernel/debug/tracing/trace

# --- clear all daemonsu (and we lost root until next reboot) --- 
# kill $(ps | grep 'daemonsu*' | awk '{print $2}')
# this requires busy box
busybox-armv7l killall daemonsu

# check: should be 0 
ps | grep daemonsu

# capture & generate zipped trace (to cater systrace) 
rm -f /sdcard/trace.txt.z

nohup atrace sched idle -b 8192 -t 30 -z \
 > /sdcard/trace.txt.z 2> /sdcard/trace.err < /dev/null &

#nohup atrace.orig sched idle -b 8192 -t 30 -z \
# > /sdcard/trace.txt.z 2> /sdcard/trace.err < /dev/null &


# unplug
# ... later ...
# plug

# --- on host ----
adb pull /sdcard/trace.txt.z /tmp/
./systrace.py  --from-file=/tmp/trace.txt.z -o /tmp/trace.html
google-chrome /tmp/trace.html
