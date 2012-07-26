set -e
#TARGET=false-sharing-org
TARGET=false-sharing
#arm-linux-gnueabi-gcc $TARGET.c  -o $TARGET -static -lpthread -lrt -g
#cc $TARGET.c  -o $TARGET-x86 -static -lpthread -lrt -g
#adb push $TARGET /data/local/

arm-none-linux-gnueabi-gcc  -static false-sharing-contention-org.c -lpthread -o /tmp/fs-arm
arm-none-linux-gnueabi-gcc  -static false-sharing-nocontention-org.c -lpthread -o /tmp/nofs-arm

gcc -g -static false-sharing-contention-org.c -lpthread -o /tmp/fs
gcc -g -static false-sharing-contention-org.c -lpthread -o /tmp/nofs

