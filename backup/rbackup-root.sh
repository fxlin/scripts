#!/bin/sh

################################################################
# rsync backup script
#
# pretty unsafe: has to be root to access /
################################################################

#	backup all files under / to a time-stamped folder in the current directory
#
#	file list: backup.lst
#
#	NOTE: this script must be run from the backup device!

DEST=./root-`date +"%m%d%y-%H_%M_%S"`

set -e

mkdir ${DEST}

su -c sh -c " rsync -av --delete-excluded --exclude-from=backup.lst / ${DEST}; \
touch ${DEST}/BACKUP \
mv ${DEST} ${DEST}-complete" 

#su -c sh -c "shutdown -h now"
#su -c sh -c "/etc/acpi/sleep.sh"

