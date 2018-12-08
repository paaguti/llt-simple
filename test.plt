set key outside;
set key right top;

set xrange [0:@NODES@]
set xlabel "Node"
set ylabel "Time (ms)"

set yrange [0:@YMAX1@]
set title "Audio Delay/Jitter"
plot "<./plotCBR @ZIPFILE@ | grep -e '^ad0'" using 2:3 w point pointtype 1 ps .5 lc rgb "blue" t "d unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^ad1'" using 2:3 w point pointtype 1 ps .5 lc rgb "green" t "d mark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^aj0'" using 2:3 w point pointtype 1 ps .5 lc rgb "red" t "j unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^aj1'" using 2:3 w point pointtype 1 ps .5 lc rgb "orange" t "j mark", \

set yrange [0:@YMAX2@]
set title "Video Delay/Jitter"
plot "<./plotCBR @ZIPFILE@ | grep -e '^vd0'" using 2:3 w point pointtype 1 ps .5 lc rgb "blue" t "d unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^vd1'" using 2:3 w point pointtype 1 ps .5 lc rgb "green" t "d mark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^vj0'" using 2:3 w point pointtype 1 ps .5 lc rgb "red" t "j unmark", \
     "<./plotCBR @ZIPFILE@ | grep -e '^vj1'" using 2:3 w point pointtype 1 ps .5 lc rgb "orange" t "j mark", \
