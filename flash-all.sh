#!/bin/bash

fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash recovery recovery.img
fastboot flash userdata userdata.img
fastboot erase cache
fastboot reboot
