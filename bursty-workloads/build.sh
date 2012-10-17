set -e
arm-linux-gnueabi-gcc test.c -o bursty -static
adb push bursty /data/local/
