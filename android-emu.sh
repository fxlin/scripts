# launch my own emulator

# first set up AOSP environment
cd /home/xzl/android-ICS/
. build/envsetup.sh

# must set this up
#lunch 1

# set up SDK dir for emulator's skin
export ANDROID_SDK_ROOT=/home/xzl/build_tools/android-sdk-linux_r18/
export ANDROID_PRODUCT_OUT=/home/xzl/android-aosp-4.0.3/out/target/product/generic

EMU=out/host/linux-x86/bin/emulator   #mine has problem in gpu support
#EMU=${ANDROID_SDK_ROOT}/tools/emulator

#${EMU} @myavd2 -partition-size 256 -gpu on

# pick up images from aosp build
${EMU} -partition-size 256 & #-gpu on
