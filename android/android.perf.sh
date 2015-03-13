#
# run perf on android and associate the data with host symbols
# in aosp.
#

###################################
#	prepare kernel symbols
###################################
# Turn on ksyms
# trick -- should run echo as root
adb shell echo 'echo 0 > /proc/sys/kernel/kptr_restrict' \| su
# should be 0
adb shell cat /proc/sys/kernel/kptr_restrict
adb pull /proc/kallsyms /tmp/kallsyms
# addresses should NOT be 00000
head /tmp/kallsyms

# push kersym to aosp tree
scp /tmp/kallsyms office:/home/xzl/aosp/out/target/product/hammerhead/symbols/

###################################
#	record perf data: run on dev host
###################################
# Turn on ksyms
# trick -- run echo as root
adb shell echo 'echo 0 > /proc/sys/kernel/kptr_restrict' \| su
# should be 0
adb shell cat /proc/sys/kernel/kptr_restrict

adb shell perf record -o /sdcard/perf.data -F 99 -ag -- sleep 10
adb pull /sdcard/perf.data
scp perf.data office:/tmp/

###################################
#	report perf data: run on office
###################################
cd /home/xzl/aosp/out/target/product/hammerhead
../../../host/linux-x86/bin/perfhost report -g -i /tmp/perf.data --symfs symbols/ --kallsyms=symbols/kallsyms


