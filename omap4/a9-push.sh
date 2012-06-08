# push userspace .out programs to the android device

set -e

OUT_DIR=/home/xzl/pandroid.gingerbread/L27.12.1-P2/mydroid/out/target/product/pandaboard/system/bin/
TARGET_DIR=/data/syslink/

echo push *.out to $TARGET_DIR
cd $OUT_DIR

files=`find -name "*.out"`
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

