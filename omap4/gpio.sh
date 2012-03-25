#!/bin/sh

set -e

echo 7 > /sys/class/gpio/export
ls /sys/class/gpio/gpio7
echo out > /sys/class/gpio/gpio7/direction
echo 1 > /sys/class/gpio/gpio7/value

