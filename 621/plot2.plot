set term pdf color enhanced rounded size 15cm,10cm font "Times-New Roman,20"
set out "621/plot2.pdf"

set xlabel "jvb version"
set xrange [601:622]
set xtics 5 

set ylabel "memory usage (MB)"
set yrange [0:600]
set ytics 50

set y2label "threads"
set y2range [0:200]
set ytics 50

set style data points
#set key off
set grid
set style line 1 lc rgb '#0060ad' pt 7 ps 3  # circle

plot 'mem_rss.data' using 1:2:($2-$3):($2+$3) with errorbars title 'memory', \
     'threads.data' using 1:2:($2-$3):($2+$3) with errorbars axes x1y2 title 'threads' \
     #'version-vs-perf' with lines, \
     #'version-vs-perf2' with points ps 2 pt 7
