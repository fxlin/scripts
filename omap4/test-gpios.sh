#!/system/bin/sh
#
# batch test a set of gpios

set -e

all_gpios="38 37 34 55 35 50 56 51 59"

for num in  `echo $all_gpios`
do
    echo "config gpio$num..."
    ./gpio.sh $num
done


for num in  $all_gpios
do
    echo "write 1 to gpio$num..."
    echo 1 > /sys/class/gpio/gpio$num/value
done

for num in  `echo $all_gpios`
do
    echo "write 0 to gpio$num..."
    echo 0 > /sys/class/gpio/gpio$num/value
done


echo "test over. did you see pulses on logic analzyer?"
