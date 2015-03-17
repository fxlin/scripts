
# Automatically generated. Don't edit. 
# NOTE: require gnuplot >=4.6
#
set title "CPU usage of top processes"
set datafile separator " "
#set terminal x11
set terminal png size 480,400 enhanced truecolor font 'Verdana,9'
set output "top.png"
set ylabel "CPU"
set xlabel "Sample"
set pointsize 0.8
set border 11
set xtics out
set tics front
set key below
plot \
  for [i=2:5:1] \
    "top.data" using 1:(sum [col=i:5] column(col)) \
        title columnheader(i) \
        with filledcurves x1 
