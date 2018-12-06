set terminal pdf color
set output "experiment1.pdf"
set title "Audio stream "
set xlabel "# of clients"
set ylabel "msec"

plot "< ./mkCBRtable llt-simple-20181205-2157.zip | awk '-F&' '/^[1-9]/ { gsub(/..$/,\"\"); if ($2 ~ /^ aud/) if ($3 ~ /^ ma/) print $1, $4}'" w l t 'delay (marking)', "< ./mkCBRtable llt-simple-20181205-2157.zip | awk '-F&' '/^[1-9]/ { gsub(/..$/,\"\"); if ($2 ~ /^ aud/) if ($3 ~ /^ ma/) print $1, $7}'" w l t 'jitter (marking)',"< ./mkCBRtable llt-simple-20181205-2157.zip | awk '-F&' '/^[1-9]/ { gsub(/..$/,\"\"); if ($2 ~ /^ aud/) if ($3 ~ /^ noma/) print $1, $4}'" w lp t 'delay (not marking)', "< ./mkCBRtable llt-simple-20181205-2157.zip | awk '-F&' '/^[1-9]/ { gsub(/..$/,\"\"); if ($2 ~ /^ aud/) if ($3 ~ /^ noma/) print $1, $7}'" w lp t 'jitter (not marking)'
