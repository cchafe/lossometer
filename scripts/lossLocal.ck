// chuck -s --caution-to-the-wind --srate:48000 lossLocal.ck:64:-1
// download loss
Std.atoi(me.arg(0)) => int FPP;
Std.atoi(me.arg(1)) => int BS;
Std.system("sox /tmp/DClocalTrim.wav /tmp/lossLocal.wav remix 3");

SndBuf snd => dac;
snd.read("/tmp/lossLocal.wav");
<<<snd.length()/minute, "minutes">>>;

0 => int cnt;
0 => int consecutive;
0 => int maxConsecutive;
FileIO fout;
snd.read("/tmp/lossLocal.wav");
fout.open("/tmp/lossLocal"+BS+".dat",FileIO.WRITE);
0.0 => float testAt;
repeat ( (Math.floor((snd.length()/samp)/FPP$float))$int ) {
  now/ms => testAt;
  0.0 => float acc;
  // FPP::samp => now;
  for (0 => int i; i < FPP; i++) {
    snd.last() +=> acc;
    1::samp => now;
  }
  if (acc!=16.0) <<<acc>>>;
  if (acc<2.0) {
    fout <= testAt/1000;
    fout <= "\t";
    fout <= 24.0; 
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
fout2.open("/tmp/stats.txt",FileIO.WRITE);
fout2 <= cnt; 
fout2 <= "\n";
fout2 <= maxConsecutive; 
fout2 <= "\n";
fout2.close();
