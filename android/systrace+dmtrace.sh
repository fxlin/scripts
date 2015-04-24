#pid=614

#pid=`adb shell busybox-armv7l pgrep system_server`
pid=$(adb shell busybox-armv7l pgrep system_server)

echo 
echo system_server pid is $pid
echo 

cd /home/xzl/build_tools/scripts/android/atrace-unplugged
source env-trace.sh
upload

cd /home/xzl/android/multi_vm_trace/
java Demo 1 $pid

tracing_start


#####################################################################################
#####################################################################################
#####################################################################################
#####################################################################################



java Stop 1 $pid
tracing_stop



#
# on device...
#

#adb shell su -c mv /data/my_trace_$pid.trace /sdcard/
su
pid=`busybox-armv7l pgrep system_server`
mv /data/*.trace /sdcard/

#
# on host
#
adb pull /sdcard/my_trace_$pid.trace /tmp/


