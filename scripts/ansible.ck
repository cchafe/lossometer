// chuck --caution-to-the-wind --srate:48000 ansible.ck
64 => int FPP;
30 => int TESTDUR;
true => int connect;
true => int record;
// 64: 7 4 -- home
// 32: 14 5 -- home

"__ffff_75.109.247.16" => string CLIENTNAMEONSERVER;
// "__ffff_98.42.48.61" => string CLIENTNAMEONSERVER;
"jacktrip/builddir/jacktrip" => string STABLE;
"jacktrip-production/jacktrip-beta" => string BETA;

"cmn9.stanford.edu" => string SERVER;
"/tmp/serverState.txt" => string ACKSERVER;
10 => int QSERVER;

"localhost" => string CLIENT;
"/tmp/clientState.txt" => string ACKCLIENT;
6 => int QCLIENT;
-1 => int BSCLIENT;

0 => int quit;
spork ~ clix(); 
spork ~ dc(); 

repeat (10) for (-1 => int BS; BS < 0; BS++) {
"plot_"+(now/minute)$int+"" => string PLOTFILENAME;
BS => int BSCLIENT;
Ansible server;
Ansible client;
if (connect) {
  server.go("startP1", SERVER, BS);
  server.wait(ACKSERVER, SERVER);
}
if (connect) { // -C need to add BS > -1
  client.go("startClient", CLIENT, BS);
  client.wait(ACKCLIENT, CLIENT);
}
if (record) {
  server.go("startDCgenerate", SERVER, BS);
  server.wait(ACKSERVER, SERVER);
}
if (record) {
  server.go("startDCrecord", SERVER, BS); // async 30"
  Std.system("ecasound -x -f:16,3,48000 -i jack,ChucK:outport\\ 0 -o /tmp/DClocal.wav  > /dev/null 2>&1 &");
  2::second => now;
}
if (record) {
  Std.system("jmess -D");
  2::second => now;
  Std.system("jack_connect ChucK:outport\\ 0 ecasound:in_1");
  Std.system("jack_connect "+SERVER+":receive_1 ecasound:in_2");
  Std.system("jack_connect "+SERVER+":receive_2 ecasound:in_3");
  Std.system("jack_connect ChucK:outport\\ 0 "+SERVER+":send_1");
  Std.system("jack_connect ChucK:outport\\ 1 "+SERVER+":send_2");
}

if (record) {
  Std.system("chuck --srate:48000 sync.ck:"+(TESTDUR+2)+" &");
  2::second => now;
  Std.system("jack_connect ChucK-01:outport\\ 0 ecasound:in_3");
  Std.system("jack_connect ChucK-01:outport\\ 0 "+SERVER+":send_2");
  TESTDUR::second => now;
}

if (record) {
  Std.system("ssh -t -Y "+SERVER+" 'killall ecasound'");
  Std.system("killall ecasound; echo local killall ecasound");
  1::second => now;
  client.go("scpDCwav", CLIENT, BS);
  client.wait(ACKCLIENT, CLIENT);
}

if (record) {
  Std.system("killall $HOME/"+STABLE+"; echo local killall $HOME/"+STABLE+"");
  server.go("stopServerProcesses", SERVER, BS);
  server.wait(ACKSERVER, SERVER);
}

if (record) {
  Std.system("chuck -s --caution-to-the-wind --srate:48000 secondPass.ck:"+(TESTDUR-5)+":"+BS+":"+FPP+":"+QSERVER+":"+QCLIENT+":"+PLOTFILENAME+"");
}

1::minute => now;

}

class Ansible {
  FileIO state;
  StringTokenizer tok;
  string str;
  fun void go (string pb, string host, int bs) {
    "ansible-playbook "+pb+".yml -i \""+host+",\" --extra-vars \"FPP="+FPP+" QSERVER="+QSERVER+" ACKSERVER="+ACKSERVER+"  QCLIENT="+QCLIENT+" ACKCLIENT="+ACKCLIENT+" SERVER="+SERVER+" BS="+bs+" CLIENTNAMEONSERVER="+CLIENTNAMEONSERVER+" STABLE="+STABLE+" BETA="+BETA+"  BSCLIENT="+BSCLIENT+" \"" => str;
    Std.system(str);
  }
  fun void wait (string ackFile, string host) {
    while (true) {
      Std.system("scp -q "+host+":"+ackFile+" "+ackFile+"");
      state.open(ackFile,FileIO.READ);
      state.readLine() => string tmp;
      if(tmp=="") {
      <<<"nothing yet\n">>>; 
        1::second => now;
      } else {
        tok.set(tmp);
        tok.next(); Std.atoi(tok.next()) => int ACKFPP;
        tok.next(); Std.atoi(tok.next()) => int ACKQ;
        "failed" => string check;
        if(FPP==ACKFPP) "passed" => check;
      <<<" ack file scp'd from "+host+" after wait ("+check+" check)","\n">>>;
        break;
      }
    }
  }
}
1 => quit;
1::second => now; // cleanup sporks

fun void clix() {
  Impulse imp => dac.chan(0);
  while (!quit) {
    imp.next (0.5);
    250::ms => now;
  }
}

fun void dc() {
  Noise dc => dac.chan(1);
  while (!quit) {
     dc.gain(0.1); 
    1::second => now;
  }
}

