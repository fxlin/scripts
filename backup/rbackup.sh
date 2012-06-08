#!/bin/sh
# rsync backup script
#
# $1 is the backup dest

DEST=./`date +"%m%d%y-%H_%M_%S"`

set -e

mkdir ${DEST}

su -c sh -c "
    rsync -av --delete-excluded --exclude-from=backup.lst / ${DEST};
        touch ${DEST}/BACKUP
        " 2>&1 1>${DEST}/BACKUP.log

su -c sh -c "shutdown -h now"

