#!/bin/sh
set -e

cd /home/xzl/pandroid.gingerbread/L27.12.1-P2/mydroid/out/target/product/pandaboard/system/lib/

adb push libipc.so /system/lib/
adb push libnotify.so /system/lib/
adb push librcm.so /system/lib/
adb push libsysmgr.so /system/lib/
