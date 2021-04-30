String test="";
// These variables define the waveform.
String vib_cmd="";
int onoff = 0;    // Keep vibrator OFF (0) or ON (1)
int inten1 = 0;   // Starting intensity for a sweep (0-255)
int inten2 = 0;   // Ending intensity for a sweep (0-255)
int sweeptime_ms = 0;   //Time for each step in ms
int repeatsweep = 0;    // no of times you want to repeat sweep within one cycle
int pulse_time_ms = 0;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
int rest_ms = 0;     // The No actuating time or resting in ms before starting next cycle

import processing.serial.*;
  Serial port;

  void setup() {
    size(256, 150);
    println("Available serial ports:");
    println(Serial.list());
    port = new Serial(this, Serial.list()[1], 9600);
    port.bufferUntil ( '\n' ); 
  }  
  void serialEvent (Serial port) {
  test = port.readStringUntil ( '\n' );
  println(test);
}

  void draw() {
    for (int i = 0; i < 256; i++) {
      stroke(i);
      line(i, 0, i, 150);
    }

    onoff = 1;    // Keep vibrator OFF (0) or ON (1)
    inten1 = mouseX;   //0 - 255
    inten2 = mouseY;   //0 - 255
    sweeptime_ms = 2;   //in ms
    repeatsweep = 2;    // no of times you want to repeat sweep within one cycle
    pulse_time_ms = 2000;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
    rest_ms = 1000;     // The No actuating time or resting in ms before starting next cycle
    vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";
    port.write(vib_cmd); 
    delay(2000); // we can use delays on Processing to run mulitple waveforms consecutively
  }
