#!/bin/sh
set -e
while read line; do
    echo $line | awk '{print $1}'
done < $1
