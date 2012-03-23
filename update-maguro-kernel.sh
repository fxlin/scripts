#!/bin/sh
# build the kernel and update it with the maguro phone
#

set -v

MY_ANDROID=/home/xzl/android-galaxymaguro/
MY_KERNEL=$MY_ANDROID/kernel
OUT=$MY_ANDROID/3rd/tuna-4.0.2-kernel-013m-felix/
OUTZIP=tuna-4.0.2-kernel-013m-felix.zip

cd $MY_KERNEL
#(make -j4)

rm -f $OUT/kernel/zImage $OUT/$OUTZIP

# incoportate the new zImage to the .zip
#
cp $MY_KERNEL/arch/arm/boot/zImage $OUT/kernel/
cd $OUT/
zip -r $OUTZIP META-INF/ kernel/ 
cd -

# put the .zip to phone sdcard, and reboot the 
# phone to recovery mode.
#
md5sum $OUT/$OUTZIP
adb push $OUT/$OUTZIP /sdcard/
adb shell md5sum /sdcard/$OUTZIP
adb reboot recovery
