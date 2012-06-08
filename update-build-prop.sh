#!/bin/sh

adb pull /system/build.prop /tmp/build.prop.back
sed /tmp/build.prop.sed '#
