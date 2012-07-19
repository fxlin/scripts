#
# plot a part of data file
# http://phaselockfel.blogspot.com/2007/05/gnuplot-plot-part-of-data-file.html
#
#
# logscale 
# set logscale X
#
# great guide for line styles: http://gnuplot.sourceforge.net/demo_cvs/dashcolor.html
#
#
#  all types of keys
# http://gnuplot.sourceforge.net/demo/key.html
#
#

   #set term png 
   set term emf "Arial,10" size 500,200

    set lmargin 1
    set bmargin 2
    set rmargin 1
    set tmargin 2
    
    set format y "%g %%"

    
    set size ratio 0.33
    

    set yrange [0:60]
    set xrange [0:80]
    
#################################################
        
        
    set title "Home"
            
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/home.emf"               
    
    plot "s2/home-swipe3.log" u  ($0/4):($4+$5)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/home-swipe3.log" u  ($0/4):($3*100) w filledcurve x1 lc rgb "blue" title "OS"
         
#################################################
        
unset key
                         
    set title "Home"
    
            
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/home5.emf"               
    

    #set label 1 "Calendar\n animation" font "Arial, 8" at 5, 50   
    #set arrow from 15,50 to 20,50
    
    plot "s2/home5.log" u ($0/4):($5+$6)*100 every ::80 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/home5.log" u ($0/4):($6*100)    every ::80 w filledcurve x1 lc rgb "blue" title "OS"
                  

#################################################

unset key
         
         
 #   set title "Pandora"
             
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/pandora.emf"               
             
    plot "s2/pandora.log" u ($0/4):($5+$6)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/pandora.log" u ($0/4):($6*100) w filledcurve x1 lc rgb "blue" title "OS"         
         
#################################################
      
unset key
         
#    set title "Youtube"         
    
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/youtube.emf"               
             
    plot "s2/youtube.log" u  ($0/4):($5+$6)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/youtube.log" u  ($0/4):($6*100) w filledcurve x1 lc rgb "blue" title "OS"           
         
#################################################
      
unset key
         
    
 #   set title "MediaServer"         
    
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/mediaserver.emf"               
             
    plot "s2/mediaserver2.log" u  ($0/4):($5+$6)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/mediaserver2.log" u  ($0/4):($6*100) w filledcurve x1 lc rgb "blue" title "OS"
         
         
#################################################
#################################################      
set key outside horiz top center
set key samplen 1.5 spacing 1 

unset title
    set xrange [0:80]
    set yrange [0:100]

    unset lmargin 
 #    unset bmargin                        
                    set ylabel "CPU Usage"
                    set xlabel "Time/Sec"
                    
                        
#             set title "Home-Swipe"     
        
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/home-swipe-w-global.emf"               
             
        
    plot "s2/home-swipe-w-global-cpu-2.log" u  ($0/4):($7+$8)*100 w filledcurve x1    lc rgb "gray" title "Rest of System", \
        "s2/home-swipe-w-global-cpu-2.log" u  ($0/4):($5+$6)*100 w filledcurve x1    lc rgb "blue" title "Thread:User", \
        "s2/home-swipe-w-global-cpu-2.log" u  ($0/4):($6*100) w filledcurve x1       lc rgb "red" title "Thread:Kernel"

#################################################
      
unset key

    set xrange [0:200]
    set yrange [0:100]
        
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/pandora-playing-songswitch-pause-w-global-cpu.emf"                            
        
    plot "s2/pandora-playing-songswitch-pause-w-global-cpu.log" u  ($0/4):($7+$8)*100 w filledcurve x1    lc rgb "gray" title "Global", \
        "s2/pandora-playing-songswitch-pause-w-global-cpu.log" u  ($0/4):($5+$6)*100 w filledcurve x1    lc rgb "blue" title "User", \
        "s2/pandora-playing-songswitch-pause-w-global-cpu.log" u  ($0/4):($6*100) w filledcurve x1       lc rgb "red" title "Kernel"         
                                       
                                       
#################################################
#################################################      
unset key
unset title

    set xrange [0:80]
    set yrange [0:100]
                    
    unset lmargin 
#    unset bmargin 
    unset rmargin 
#    unset tmargin 
                        
                    set ylabel "CPU Usage"
                    set xlabel "Time/Sec"
                    
    set output "/home/xzl/Dropbox/measurements/cpu-usage/per-thread-usr-sys/output/gmail-typing-opening-reading-opening-w-globalcpu.emf"                            
        
    plot "s2/gmail-typing-opening-reading-opening-w-globalcpu.log" u  ($0/4):($7+$8)*100 w filledcurve x1    lc rgb "gray" title "Rest of System", \
        "s2/gmail-typing-opening-reading-opening-w-globalcpu.log" u  ($0/4):($5+$6)*100 w filledcurve x1    lc rgb "blue" title "Thread-User", \
        "s2/gmail-typing-opening-reading-opening-w-globalcpu.log" u  ($0/4):($6*100) w filledcurve x1       lc rgb "red" title "Kernel"         
                                       
                                       
                                                                              
