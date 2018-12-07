set xrange [-1:6]
set yrange [0:100]
set title "Delay"
set xlabel "Node"
set ylabel "Delay(ms)"
plot "<./plotCBR @ZIPFILE@ | grep -e '^0'" using 2:3 t "unmarked", "<./plotCBR @ZIPFILE@ | grep -e '^1'" using 2:3 t "marked"
