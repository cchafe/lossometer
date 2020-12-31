// chuck sync.ck:10
Std.atoi(me.arg(0)) => int TESTDUR;
false => int quit;
Impulse imp => dac.chan(0);
0 => int cnt;
while (!quit) {
  if (cnt == 5) imp.next(0.8); 
  1::second => now;
  cnt++;
  if (cnt >= TESTDUR) true => quit; 
}
