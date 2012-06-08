#!/bin/sh
set -e

MYPATH=/home/xzl/Dropbox/measurements/
PREFIX=`basename $PWD`

echo "<<<<<<<<<<<<< Merge files <<<<<<<<<<<<<"
${MYPATH}/ordered-cat.sh

echo "<<<<<<<<<<<<< Proc merged file <<<<<<<<<<<<<"
${MYPATH}/analyzer.py ${PREFIX}.out > ${PREFIX}.res

echo "<<<<<<<<<<<<< Done.<<<<<<<<<<<<<"
