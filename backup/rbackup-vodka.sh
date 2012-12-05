#!/bin/sh

################################################################
# rsync backup script
# safer - don't have to be root here
################################################################

################################################################
#  --- relys on .rsync-filter under /media/vodka/.rsync-filter
################################################################

SRC=/media/vodka
DEST=./vodka-`date +"%m%d%y-%H_%M_%S"`

set -e

mkdir ${DEST}

#'delte-excluded' used to remove files from dest if they're not in src. not useful for new backups.

#su -c sh -c "rsync -a -vv --delete-excluded --filter='dir-merge /.rsync-filter' ${SRC} ${DEST}; touch ${DEST}/BACKUP " 

# DRY RUN, for debugging#
#su -c sh -c "rsync -a -vv --filter='dir-merge /.rsync-filter' --dry-run  /media/vodka/ /media/backup-storage/vodka-102512-12_34_35/

# ACTUAL RUN #
rsync -a -vv --filter='dir-merge /.rsync-filter' ${SRC} ${DEST}; \
touch ${DEST}/BACKUP; \
mv ${DEST} ${DEST}-complete; 

# ---------------
# make it easier to view ..
#su -c sh -c "chown xzl:xzl -R ${DEST}/"

# ---- power down ----
#su -c sh -c "shutdown -h now"
#su -c sh -c "/etc/acpi/sleep.sh"

