#!/bin/sh
for F in logs/*.log
do
	OUT=`echo $F | sed 's/\.log/\.html/g'`
	echo $F to ${OUT}
	cat $F | ./ansi2html.sh > ${OUT}
done

