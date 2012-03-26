#!/system/bin/sh

# enable GPIO #NUM, set it to the output mode, and change its value to 1
# 
# Usage ./gpio.sh [pin_num]

set -e
#set -v

#NUM=7
NUM=$1
echo $NUM > /sys/class/gpio/export
[ -d /sys/class/gpio/gpio$NUM ] || { echo "error: dev file dir no exist."; exit 1; }  
echo out > /sys/class/gpio/gpio$NUM/direction
echo 0 > /sys/class/gpio/gpio$NUM/value

