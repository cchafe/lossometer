// chuck -s --caution-to-the-wind --srate:48000 secondPass.ck:25:-1:64:12:6
Std.atoi(me.arg(0)) => int TRIMDUR;
Std.atoi(me.arg(1)) => int BS;
Std.atoi(me.arg(2)) => int FPP;
Std.atoi(me.arg(3)) => int QSERVER;
Std.atoi(me.arg(4)) => int QCLIENT;
Std.system("chuck -s --caution-to-the-wind --srate:48000 trimLocal.ck:"+TRIMDUR+"");
Std.system("chuck -s --caution-to-the-wind --srate:48000 trimRemote.ck:"+TRIMDUR+"");
{

<<<"2nd pass">>>;
  "
chuck -s --caution-to-the-wind --srate:48000 /home/cc/Desktop/153/153bIETF/ck/bufferDynamics.ck:"+BS+"
  " => string str;
  Std.system(str);

// local
true => int local;
  "
chuck -s --caution-to-the-wind --srate:48000 loss.ck:"+FPP+":"+BS+":"+local+"
  " => str;
Std.system(str); // rewrite stats.txt
  "
chuck -s --caution-to-the-wind --srate:48000 loss.ck:"+FPP+":"+BS+":"+!local+"
  " => str;
Std.system(str); // append stats.txt

  FileIO fout;
  fout.open("/tmp/plot.txt",FileIO.WRITE);
  "set title \""+BS+" "+FPP+" server:"+QSERVER+" client:"+QCLIENT+" " => str;
  fout <= str;
  fout.close();

  FileIO fin;
  StringTokenizer tok;
  fin.open("/tmp/stats.txt",FileIO.READ);
  fin.readLine() => string line;
  tok.set( line );
  Std.atoi( tok.next() ) => int DOWNLOSS;
  fin.readLine() => line;
  tok.set( line );
  Std.atoi( tok.next() ) => int DOWNCONSECUTIVE;
  fin.readLine() => line;
  tok.set( line );
  Std.atoi( tok.next() ) => int UPLOSS;
  fin.readLine() => line;
  tok.set( line );
  Std.atoi( tok.next() ) => int UPCONSECUTIVE;

  "
chuck -s  --caution-to-the-wind /home/cc/Desktop/153/153bIETF/ck/gnuplot.ck:"+BS+":"+UPLOSS+":"+DOWNLOSS+":"+UPCONSECUTIVE+":"+DOWNCONSECUTIVE+"
  " =>  str;
  Std.system(str);
}

