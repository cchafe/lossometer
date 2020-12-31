// chuck -s --srate:48000  --caution-to-the-wind bufferDynamics.ck:-1
Std.atoi(me.arg(0)) => int BS;

Std.system("sox /tmp/DClocalTrim.wav /tmp/clix1.wav remix 1");
Std.system("sox /tmp/DClocalTrim.wav /tmp/clix2.wav remix 2");
Std.system("sox -M /tmp/clix1.wav /tmp/clix2.wav /tmp/clixBS"+BS+".wav");

SndBuf2 snd => dac;
snd.read("/tmp/clixBS"+BS+".wav");
<<<snd.length()/minute, "minutes">>>;

FileIO fout;
fout.open("/tmp/clixBS"+BS+".dat",FileIO.WRITE);
FileIO fout2;
fout2.open("/tmp/clixMissedBS"+BS+".dat",FileIO.WRITE);
snd.read("/tmp/clixBS"+BS+".wav");
0.0 => float impAt;
0.0 => float echoAt;
false => int lastWasImp;
repeat (snd.length()/samp) {
  if (snd.chan(0).last()>0.01) {
    if (!lastWasImp) {
      now/ms => impAt;
      true => lastWasImp;
    } else { // missed an echo
      fout2 <= impAt/1000;
      fout2 <= "\t";
      fout2 <= 22.0;
      fout2 <= "\n";
    }
  }
  if (lastWasImp &&
  (snd.chan(1).last()>0.01)) {
    now/ms => echoAt;
    false => lastWasImp;
//    <<<snd.chan(1).last(),echoAt-impAt>>>;
    fout <= impAt/1000;
    fout <= "\t";
    fout <= (echoAt-impAt);
//    fout <= (echoAt-impAt)/msPerBuf; // expressed in number of buffers
    fout <= "\n";
  }
  1::samp => now;
}
fout.close();
fout2.close();
