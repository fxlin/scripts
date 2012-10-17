# push to the android device
# !!! the trailing / is a must !!!

set -e

#TARGET_DIR=/data/syslink/
TARGET_DIR=/system/bin/

echo push *.xem3 to $TARGET_DIR
echo ========== push to android devices ==========
#find -name *.xem3 -exec adb push {} /system/bin/ \;
#find -name *.xem3 -exec adb push {} /sdcard/ \;

#adb push test.sh $TARGET_DIR/
#adb push gpio.sh $TARGET_DIR/

files=`find -name "*.xem3"`
for f in $files 
do
    T=$TARGET_DIR/`basename $f`
    m1=`adb shell md5sum $T | awk '{print $1}'`
    m2=`md5sum $f | awk '{print $1}'`
    if [ "$m1" != "$m2" ]
    then
        echo copy $f
        adb push $f $TARGET_DIR/
    else
        echo skip $f
    fi
done
