#!/bin/sh

#
# fs pattern 1 for filled style
# color: lc rgb "blue" 
#
# size: set size 1, 0.5  # does not change canvas size
# size: set size ratio 0.5 
#
# crop: set term $TERMINAL crop  # works for png
#       about EMF: http://objectmix.com/graphics/139879-remove-extra-space-emf-terminal-output.html  set canvas size in term
# margin:
#    set lmargin 1
#    set bmargin 1
#    set rmargin 1
#    set tmargin 1
#
    
set -e
#INPUTS="browsing home-static maguro.home-swipe stopwatch youtube texting"
#INPUTS="maguro.home-swipe "
#INPUTS="s2.memmpac-default s2.youtube s2.home-static s2.texting s2.smartbench s2.atutu-io-sdcard s2.camcording s2.browser-mark "$INPUTS
#INPUTS="s2/home-swipe"
INPUTS="res/*.txt"
#INPUTS="browsing"

rm -rf png/
mkdir -p "png"

TERMINAL=png
#OPTIONS=crop

#TERMINAL=emf
#OPTIONS="Arial,10" size 600,200

#TERMINAL=svg
#TERMINAL=postscript

echo $INPUTS

for fname in `echo $INPUTS`
do
    gnuplot << EOF
    #set term png crop
    
    #set term emf "Arial,10" size 600,200    
    set term $TERMINAL $OPTIONS
        
    set xrange [1:11]
    set yrange [0.5:1]

    #set key outside horiz top center
    set key  vertical left 

    set output "png/`basename $fname`.$TERMINAL"

    # example for plotting data blocks (datablock)
    
    plot "$fname" index 0 u 2:4 w linespoints title "m=2", \
    "$fname" index 1 u 2:4 w linespoints title "m=3", \
    "$fname" index 2 u 2:4 w linespoints title "m=4", \
    "$fname" index 3 u 2:4 w linespoints title "m=5", \
    "$fname" index 4 u 2:4 w linespoints title "m=6", \
    "$fname" index 5 u 2:4 w linespoints title "m=7", \
    "$fname" index 6 u 2:4 w linespoints title "m=8", \
    "$fname" index 7 u 2:4 w linespoints title "m=9", \
    "$fname" index 8 u 2:4 w linespoints title "m=10"

EOF
done
