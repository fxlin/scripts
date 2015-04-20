# --- on device ----

su

# --- enable w for nonroot --- 
# with patched kernel, these won't be necessary
chmod 777 /sys/kernel/debug/tracing/events/power/cpu_idle/enable
chmod 777 /sys/kernel/debug/tracing/events/sched/sched_switch/enable
chmod 777 /sys/kernel/debug/tracing/events/sched/sched_wakeup/enable
chmod 777 /sys/kernel/debug/tracing/events/ext4/ext4_da_write_begin/enable 
chmod 777 /sys/kernel/debug/tracing/events/ext4/ext4_da_write_end/enable 
chmod 777 /sys/kernel/debug/tracing/events/ext4/ext4_sync_file_enter/enable 
chmod 777 /sys/kernel/debug/tracing/events/ext4/ext4_sync_file_exit/enable 
chmod 777 /sys/kernel/debug/tracing/events/block/block_rq_issue/enable 
chmod 777 /sys/kernel/debug/tracing/events/block/block_rq_complete/enable 
        
chmod 777 /sys/kernel/debug/tracing/options/overwrite
chmod 777 /sys/kernel/debug/tracing/buffer_size_kb
chmod 777 /sys/kernel/debug/tracing/options/print-tgid
chmod 777 /sys/kernel/debug/tracing/tracing_on
chmod 777 /sys/kernel/debug/tracing/trace_clock
chmod 777 /sys/kernel/debug/tracing/trace

# --- clear all daemonsu (and we lost root until next reboot) --- 
# kill $(ps | grep 'daemonsu*' | awk 'print $2')
# this requires busy box
busybox-armv7l killall daemonsu

# check: should be 0 
ps | grep daemonsu

rm -f /sdcard/trace.txt.z

