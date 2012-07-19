cat /proc/`pgrep youtube`/stat | awk '{print "utime", $14, "ktime",  $15}'

