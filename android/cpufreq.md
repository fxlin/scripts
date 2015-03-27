# --- max core freq -----

echo 1190400 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq

adb logcat -s ActivityManager

# --- online all 4 cores -----

cat /sys/devices/system/cpu/online
cat /sys/devices/system/cpu/offline
cat /sys/devices/system/cpu/present

echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online

cat /sys/devices/system/cpu/online
