set -e

arm-linux-gnueabi-gcc test.c -o bursty -static

adb shell "mkdir -p /data/local/"

adb push bursty /data/local/
adb push nohup /data/local/
