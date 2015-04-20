set -e

TARGETDIR=/sdcard/unplugged
SYSTRACE=/home/xzl/build_tools/scripts/android/systrace/systrace.py

upload ()
{
  # sync all scripts to target
  adb shell mkdir $TARGETDIR

  F="*device*"
  for f in $F
  do 
    adb push $f $TARGETDIR
  done
}

tracing_prepare ()
{
  adb shell sh $TARGETDIR/device-prepare.sh
}

tracing_start ()
{
  adb shell sh $TARGETDIR/device-start.sh
}

tracing_stop ()
{
  adb shell sh $TARGETDIR/device-stop.sh

  rm -f /tmp/trace.txt.z
  adb pull /sdcard/trace.txt.z /tmp/
  $SYSTRACE  --from-file=/tmp/trace.txt.z -o /tmp/trace.html
  google-chrome /tmp/trace.html
}


