set key outside bottom center;

set xrange [0:@NODES@]
set xlabel "Node"
set ylabel "Time (ms)"

set yrange [0:@YMAX1@]
set title "Audio Delay/Jitter"
plot "<./plotCBR @ZIPFILE@ | grep -e '^ad0'" using 2:3 w p pt 1 ps .75 lc rgb "blue"   t "delay unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^ad1'" using 2:3 w p pt 1 ps .75 lc rgb "green"  t "delay mark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^aj0'" using 2:3 w p pt 2 ps .75 lc rgb "red"    t "jitter unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^aj1'" using 2:3 w p pt 2 ps .75 lc rgb "orange" t "jitter mark", \

set yrange [0:@YMAX2@]
set title "Video Delay/Jitter"
plot "<./plotCBR @ZIPFILE@ | grep -e '^vd0'" using 2:3 w p pt 1 ps .75 lc rgb "blue"   t "delay unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^vd1'" using 2:3 w p pt 1 ps .75 lc rgb "green"  t "delay mark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^vj0'" using 2:3 w p pt 2 ps .75 lc rgb "red"    t  "jitter unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^vj1'" using 2:3 w p pt 2 ps .75 lc rgb "orange" t "jitter mark", \
