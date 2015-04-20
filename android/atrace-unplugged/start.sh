#!/bin/bash

TARGETDIR=/sdcard/unplugged

# sync all scripts to target
adb shell mkdir $TARGETDIR

F="*device*"
for f in $F
do 
adb push $f $TARGETDIR
done

adb shell sh $TARGETDIR/2-device-start.sh
echo "now you can unplug..."

