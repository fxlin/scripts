##############################
# START TRACING
##############################
# NOTE: 
CAT="sched idle gfx am input"
DELAYSTART=5
ATRACE=atrace
#ATRACE=atrace.orig   # stock binary

#nohup atrace sched idle -b 8192 -t 30 -z \
# > /sdcard/trace.txt.z 2> /sdcard/trace.err < /dev/null &

#$ATRACE $CAT -b 8192 -s $DELAYSTART -t 60 --async_start -n

# start async
# with async, does "-t" matter?
$ATRACE $CAT -o uptime-xzl -b 8192 -t 60 --async_start -c

# do we have atrace running?
ps | grep $ATRACE


# unplug
# ... later ...
# plug

