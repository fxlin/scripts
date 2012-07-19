set -e
#TARGET=false-sharing-org
TARGET=false-sharing
arm-linux-gnueabi-gcc $TARGET.c  -o $TARGET -static -lpthread -lrt -g
#cc $TARGET.c  -o $TARGET-x86 -static -lpthread -lrt -g
adb push $TARGET /data/local/
