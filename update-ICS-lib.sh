#!/bin/sh
# build an ICS .so lib and put it to the phone
#
# tested on maguro + ICS

ANDROID_ROOT=/home/xzl/android.ICS/
SRC=$ANDROID_ROOT/frameworks/base/services/input/
TARGET=$ANDROID_ROOT/out/target/product/generic/system/lib/libinput.so

# set up the Android build env
source $ANDROID_ROOT/build/envsetup.sh

# build the lib
cd $SRC
mm

# put phone /system to r/w
#
adb shell /data/local/remount-maguro.sh

# upload the compiled lib
adb push $TARGET /system/lib/

# cmp their md5sum
md5sum $TARGET
adb shell md5sum /system/lib/libinput.so
