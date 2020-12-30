// chuck -s --caution-to-the-wind --srate:48000 trimRemote.ck:10:-1
// download loss
Std.atoi(me.arg(0)) => int TRIMDUR;
Std.atoi(me.arg(1)) => int BS;

SndBuf snd => dac;
snd.read("/tmp/DC.wav");
<<<snd.length()/minute, "minutes">>>;

FileIO fout;
snd.read("/tmp/DC.wav");
fout.open("/tmp/syncRemote.dat",FileIO.WRITE);
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
Std.system("sox /tmp/DC.wav /tmp/lossRemote.wav trim "+syncAt+" "+TRIMDUR+"");

