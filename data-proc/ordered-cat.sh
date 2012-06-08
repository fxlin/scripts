#!/bin/sh

set -e

PREFIX=`basename $PWD`

echo "cleaning ${PREFIX}.out"
rm -rf ${PREFIX}.out

NUM_FILES=`ls *.txt | wc -l`

for (( c=0; c<${NUM_FILES}; c++ ))do
    echo "cat ${PREFIX}_$c.txt";
    cat ${PREFIX}_$c.txt >> ${PREFIX}.out;
done 
#done

