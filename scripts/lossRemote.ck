// chuck -s --caution-to-the-wind --srate:48000 lossRemote.ck:64:-1
// download loss
Std.atoi(me.arg(0)) => int FPP;
Std.atoi(me.arg(1)) => int BS;

SndBuf snd => dac;
snd.read("/tmp/lossRemote.wav");
<<<snd.length()/minute, "minutes">>>;

0 => int cnt;
0 => int consecutive;
0 => int maxConsecutive;
FileIO fout;
snd.read("/tmp/lossRemote.wav");
fout.open("/tmp/lossRemote"+BS+".dat",FileIO.WRITE);
0.0 => float testAt;
repeat ( (Math.floor((snd.length()/samp)/FPP$float))$int ) {
  now/ms => testAt;
  FPP::samp => now;
  if (snd.last()==0.0) {
    fout <= testAt/1000;
    fout <= "\t";
    fout <= 25.0; 
    fout <= "\n";
    cnt++;
    consecutive++;
  } else {
    if (consecutive>maxConsecutive) consecutive => maxConsecutive;
    0 => consecutive;
  }
}
fout.close();

FileIO fout2;
fout2.open("/tmp/stats.txt",FileIO.APPEND);
fout2 <= cnt; 
fout2 <= "\n";
fout2 <= maxConsecutive; 
fout2 <= "\n";
fout2.close();
