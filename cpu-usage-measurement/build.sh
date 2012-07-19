set -e
arm-linux-gnueabi-gcc procstat-cpu-simple.c  -o procstat-cpu-simple -static
adb push procstat-cpu-simple /data/local/
