export TARGETDIR=/sdcard/unplugged
export SYSTRACE=/home/xzl/build_tools/scripts/android/systrace/systrace.py

upload()
{
  #set -e 
  # sync all scripts to target
  adb shell mkdir $TARGETDIR

  F="*device*"
  for f in $F
  do 
    adb push $f $TARGETDIR
  done
}

# XXX this can't be automated yet.
tracing_prepare()
{
#  set -e
  adb shell sh $TARGETDIR/device-prepare.sh
}

tracing_start()
{
  echo "Warning: daemonsu might run periodically. to kill it, on device: "
  echo 
  echo "    su"
  echo "    busybox-armv7l killall daemonsu"
  echo
  
  adb shell sh $TARGETDIR/device-start.sh

  echo 
  echo "You can unplug the device now."
  echo "To stop, plug back in the device and run tracing_stop."
}

tracing_stop()
{
#  set -e
  adb shell sh $TARGETDIR/device-stop.sh

  rm -f /tmp/trace.txt.z
  adb pull /sdcard/trace.txt.z /tmp/
  $SYSTRACE  --from-file=/tmp/trace.txt.z -o /tmp/trace.html
  google-chrome /tmp/trace.html
}

echo "Loading commands ..."
echo 
echo 
echo "Command:"
echo "upload           copy the device-side scripts through adb."
echo "tracing_start    start tracing (unplugged supported)"
echo "tracing_stop     stop tracing, collect results, and show in the browser"
echo 
echo "Note: Tracing options, e.g., clock, event categories, can be changed in device-*.sh." 
echo "      Make sure run \"upload\" after changing these scripts."
