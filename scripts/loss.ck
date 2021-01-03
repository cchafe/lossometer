// chuck -s --caution-to-the-wind --srate:48000 loss.ck:64:-1:1
// download loss
Std.atoi(me.arg(0)) => int FPP;
Std.atoi(me.arg(1)) => int BS;
Std.atoi(me.arg(2)) => int local;
if (local) Std.system("sox /tmp/DClocalTrim.wav /tmp/lossLocal.wav remix 3");

SndBuf snd => dac;
if (local) snd.read("/tmp/lossLocal.wav"); else snd.read("/tmp/lossRemote.wav");
<<<snd.length()/minute, "minutes">>>;

0 => int pCnt;
0 => int cnt;
0 => int consecutive;
0 => int maxConsecutive;
FileIO fout;
if (local) snd.read("/tmp/lossLocal.wav"); else snd.read("/tmp/lossRemote.wav");
if (local) fout.open("/tmp/lossLocal"+BS+".dat",FileIO.WRITE); else fout.open("/tmp/lossRemote"+BS+".dat",FileIO.WRITE);
0.0 => float testAt;
(FPP-1)::samp => now; // align with packet
repeat ( (Math.floor((snd.length()/samp)/FPP$float))$int ) {
  now/ms => testAt;
  pCnt++;
  0.0 => float acc;
  // FPP::samp => now;
  for (0 => int i; i < FPP; i++) {
    snd.last() +=> acc;
    1::samp => now;
  }
//  if (acc!=FPP*0.5) <<<acc, pCnt>>>; // DC = 0.5
  if (acc==0.0) {
    fout <= testAt/1000;
    fout <= "\t";
// if (local) fout <= 24.0; else fout <= 25.0;
if (local) fout <= 90.0; else fout <= 95.0;
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
if (local) fout2.open("/tmp/stats.txt",FileIO.WRITE); else fout2.open("/tmp/stats.txt",FileIO.APPEND);
fout2 <= cnt; 
fout2 <= "\n";
fout2 <= maxConsecutive; 
fout2 <= "\n";
fout2.close();
