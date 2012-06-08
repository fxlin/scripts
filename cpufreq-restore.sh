#!/bin/sh
set -e

su -c "echo 2534000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
su -c "echo 2534000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq"

cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

