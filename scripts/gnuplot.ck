// chuck -s --caution-to-the-wind gnuplot.ck:-1:10:10
Std.atoi(me.arg(0)) => int BS;
Std.atoi(me.arg(1)) => int UPLOSS;
Std.atoi(me.arg(2)) => int DOWNLOSS;
Std.atoi(me.arg(3)) => int UPCONSECUTIVE;
Std.atoi(me.arg(4)) => int DOWNCONSECUTIVE;

FileIO fout;
fout.open("/tmp/plot.txt",FileIO.APPEND); // caller does WRITE with title
// fout.open("/tmp/plot.txt",FileIO.WRITE); // caller does WRITE with title
"
# set yrange[75:95] # 256
# set yrange[30:50] # 64
# set yrange[15:35] # 32
set yrange[20:250] # fishing around
set label \"lost packets\" at graph 0.1,0.15 left font \"Ariel,14\"
set label \"upload     "+UPLOSS+" "+UPCONSECUTIVE+"\" at graph 0.13,0.1 left font \"Ariel,14\"
set label \"download     "+DOWNLOSS+"  "+DOWNCONSECUTIVE+"\" at graph 0.13,0.05 left font \"Ariel,14\"
plot '/tmp/clixBS"+BS+".dat' u ($1/60):2 w l, '/tmp/lossLocal"+BS+".dat' u ($1/60):2 lt 7, '/tmp/lossRemote"+BS+".dat' u (($1)/60):2 lt 6,  '/tmp/clixMissedBS"+BS+".dat' u ($1/60):2 lt 5
" => string str;
fout <= str;
fout.close();
"gnuplot \"/tmp/plot.txt\" --persist
" => str;
Std.system(str);

