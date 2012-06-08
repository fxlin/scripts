source /home/xzl/.bashrc

CONFIG=full_maguro-eng

export CC=gcc-4.4
export CXX=g++-4.4

cd /home/xzl/android-aosp-4.0.1
source build/envsetup.sh
lunch ${CONFIG}
export ANDROID_SERIAL=0149A97C1101400B
echo "setting up adb env for ${CONFIG}"

