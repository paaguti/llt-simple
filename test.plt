@KEY@

set xrange [0:@NODES@]
set xlabel "Node"
set ylabel "Time (ms)"

set yrange [0:@YMAX1@]
set title "@TIT1@"
plot "<./plotCBR @ZIPFILE@ | grep -e '^@T1@'" using 2:3 w p pt 1 ps .75 lc rgb "blue"   t "@G1@", \
     "<./plotCBR @ZIPFILE@ | grep -e '^@T2@'" using 2:3 w p pt 1 ps .75 lc rgb "green"  t "@G2@", \
     "<./plotCBR @ZIPFILE@ | grep -e '^@T3@'" using 2:3 w p pt 2 ps .75 lc rgb "red"    t "@G3@", \
     "<./plotCBR @ZIPFILE@ | grep -e '^@T4@'" using 2:3 w p pt 2 ps .75 lc rgb "orange" t "@G4@"

set yrange [0:@YMAX2@]
set title "@TIT2@ Delay/Jitter"
plot "<./plotCBR @ZIPFILE@ | grep -e '^@T5@'" using 2:3 w p pt 1 ps .75 lc rgb "blue"   t "@G5@", \
     "<./plotCBR @ZIPFILE@ | grep -e '^@T6@'" using 2:3 w p pt 1 ps .75 lc rgb "green"  t "@G6@", \
     "<./plotCBR @ZIPFILE@ | grep -e '^@T7@'" using 2:3 w p pt 2 ps .75 lc rgb "red"    t "@G7@", \
     "<./plotCBR @ZIPFILE@ | grep -e '^@T8@'" using 2:3 w p pt 2 ps .75 lc rgb "orange" t "@G8@"
