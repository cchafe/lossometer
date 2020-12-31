// chuck -s --caution-to-the-wind --srate:48000 trimLocal.ck:10:-1
// download loss
Std.atoi(me.arg(0)) => int TRIMDUR;
Std.atoi(me.arg(1)) => int BS;
Std.system("sox /tmp/DClocal.wav /tmp/syncLocal.wav remix 3");

SndBuf snd => dac;
snd.read("/tmp/syncLocal.wav");
<<<snd.length()/minute, "minutes">>>;

FileIO fout;
snd.read("/tmp/syncLocal.wav");
fout.open("/tmp/syncLocal"+BS+".dat",FileIO.WRITE);
0.0 => float syncAt;
repeat (snd.length()/samp) {
  now/second => syncAt;
  if (snd.last() > 0.6) {
    fout <= syncAt;
    fout <= "\n";
    break;
  }
  1::samp => now;
}
fout.close();
Std.system("sox /tmp/DClocal.wav /tmp/DClocalTrim.wav trim "+syncAt+" "+TRIMDUR+"");

