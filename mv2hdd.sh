#!/bin/sh

set -e

#HDD=/media/a6b707b5-db4a-41d4-9f88-c0e67b7294a0
#HDD=/home/xzl/HDD
HDD=/media/vodka

[ -e $1 ] || { echo "missing target file/dir"; exit 1; }
[ -h $1 ] && { echo "$1 is a sym link"; exit 1; }

REALNAME=`realpath $1`
REALDIR=`dirname ${REALNAME}`

[ -d ${HDD} ] || { echo HDD ${HDD} does not exist; exit 1; }

[ -d ${HDD}/${REALDIR} ] || { echo mkdir ${HDD}/${REALDIR}; mkdir -p ${HDD}/${REALDIR}; }

rsync -avxP --delete ${REALNAME}/ ${HDD}/${REALNAME}/

# only at this time we're good to del the original file...

set -x
rm -rf ${REALNAME}/
set +x

ln -s ${HDD}/${REALNAME} ./

ls -l ${REALNAME}
echo "OK"
