source /home/xzl/.bashrc

export CC=gcc-4.4
export CXX=g++-4.4

cd /home/xzl/android-aosp-4.0.1
source build/envsetup.sh
lunch 1
export ANDROID_SERIAL=emulator-5554
echo "setting up adb env for Android maguro phone..."

