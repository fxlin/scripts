#!/system/bin/sh
set -e

KERNEL_BEG=`grep " _text" /proc/kallsyms | awk '{print $1}'`
echo $KERNEL_BEG
KERNEL_END=`grep " _etext" /proc/kallsyms | awk '{print $1}'`
echo $KERNEL_END

./opcontrol --list-events
./opcontrol --reset --vmlinux=/data/local/vmlinux --kernel-range=0x$KERNEL_BEG,0x$KERNEL_END --event=CPU_CYCLES:150000 --setup --status
./opcontrol --start

sleep 1

./opcontrol --status

echo "..done." 
