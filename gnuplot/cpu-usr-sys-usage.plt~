   #set term png 
   set term emf "Arial,10" size 600,600    

set multiplot layout 3, 1 
#    set output "/tmp/out.emf"       
    set lmargin 1
    set bmargin 2
    set rmargin 1
    set tmargin 2
    
    set format y "%g %%"
    set title "plot 1"
    
    set size ratio 0.33
    
    set yrange [0:60]
    set xrange [0:160]
        
    plot "s2/home-swipe3.log" u :($4+$5)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/home-swipe3.log" u :($3*100) w filledcurve x1 lc rgb "blue" title "OS"

#################################################

unset key
         
    plot "s2/pandora.log" u :($4+$5)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/pandora.log" u :($3*100) w filledcurve x1 lc rgb "blue" title "OS"         
         
#################################################
         
    plot "s2/youtube.log" u :($4+$5)*100 w filledcurve x1 lc rgb "gray" title "User", \
         "s2/youtube.log" u :($3*100) w filledcurve x1 lc rgb "blue" title "OS"           
