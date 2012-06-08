#!/bin/sh
#
# go to the path where all *.imgs reside, then...
#
tar -jcvf boot.tar.bz2 boot.img
tar -jcvf system.tar.bz2 system.img
tar -jcvf userdata.tar.bz2 userdata.img
sudo linaro-android-media-create --mmc /dev/mmcblk0 --dev panda --system system.tar.bz2 --userdata userdata.tar.bz2 --boot boot.tar.bz2
