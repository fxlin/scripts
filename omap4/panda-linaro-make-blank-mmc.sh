#!/bin/sh
#
set -e

cd /tmp
dd if=/dev/random of=zero bs=512 count=1
tar -jcvf zero.tar.bz2 zero
sudo linaro-android-media-create --mmc /dev/mmcblk0 --dev panda --system zero.tar.bz2 --userdata zero.tar.bz2 --boot zero.tar.bz2

cd ~/android.ICS/
sudo cp device/ti/panda/xloader.bin /media/boot/MLO
sudo cp device/ti/panda/bootloader.bin /media/boot/u-boot.bin
sudo umount /media/boot/

echo "now the MMC should boot panda into fastboot"
