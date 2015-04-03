# --- on device ----
su

#CAT="sched gfx view wm"		# android's tutorial
#CAT="sched idle"
CAT="input app"
SECONDS=10

atrace sched $CAT -b 8192 -t $SECONDS -z > /sdcard/trace.txt.z


# --- on host ----
adb pull /sdcard/trace.txt.z /tmp/
./systrace.py  --from-file=/tmp/trace.txt.z -o /tmp/trace.html
google-chrome /tmp/trace.html
