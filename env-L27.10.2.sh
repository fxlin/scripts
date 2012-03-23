# for mkimage
export PATH=$PATH:/home/xzl/pandroid.froyo/pandroid.froyo/L27.10.2-P1/u-boot/tools/

# for cross compile
export PATH=/home/xzl/build_tools/arm-2010q1/bin:$PATH


export CC=arm-none-linux-gnueabi-gcc
export ARCH=arm		# small case is important!
export CROSS_COMPILE=arm-none-linux-gnueabi-
