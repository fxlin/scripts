##############################
# STOP TRACING
# XXX: the options here must match device-start?
##############################
ATRACE=atrace
CAT="sched idle gfx am input"

rm -f /sdcard/trace.txt.z
# somehow --aync_stop does not work well with -z?
#$ATRACE $CAT --async_stop -z > /sdcard/trace.txt.z
$ATRACE $CAT -o uptime-xzl --async_dump -z > /sdcard/trace.txt.z
$ATRACE $CAT -o uptime-xzl --async_stop > /dev/null

ls -l /sdcard/trace.txt.z
