//Karthik

//sound 
import guru.ttslib.*;

import org.gicentre.utils.stat.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.*;
import guru.ttslib.*;
import javax.sound.sampled.*;

TTS tts;
Minim       minim;
AudioOutput out;
Oscil       wave;
Mixer.Info[] mixerInfo;

//

import org.gicentre.utils.stat.*;

private PVector dataPoint;
private int barIndex;
private float yValue;

private float barHeight;
private float[] barValues = {70, 40, 80, 50, 30}; // barchart values
private String[] barNames = new String[] {"Canada","Australia","England",
                                       "New Zealand","Germany"};

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
float barH = 0;

import processing.serial.*;
  Serial port;
  
BarChart barChart;
 
void setup()
{
  size(600,600);

  port = new Serial(this, Serial.list()[0], 9600);
  port.bufferUntil ( '\n' ); 
  
  barChart = new BarChart(this);
  barChart.setData(barValues);
  barChart.setBarLabels(barNames);
  
  barChart.setMinValue(0);
  barChart.setMaxValue(100);
  
  barChart.showValueAxis(true);
  barChart.showCategoryAxis(true); 
  

  
        //give sound
      minim = new Minim(this);
      out = minim.getLineOut();
      wave = new Oscil(200, 0.0f, Waves.SINE);
      wave.patch(out);
      tts = new TTS();
      //
}

void serialEvent (Serial port) 
{
  test = port.readStringUntil ( '\n' );
  println(test);
}
 
void draw()
{
  background(255, 255, 255);
  barChart.draw(15, 15, width - 30, height - 30);
   
  fill(120);
  textSize(14);
  text("Populations in Countries", 70,30);
  
  dataPoint = barChart.getScreenToData(new PVector(mouseX, mouseY));
  //print("Datapoint: ");
  //println(dataPoint);
  if (dataPoint != null)
  {
    barIndex = (int)dataPoint.x;
    yValue = dataPoint.y;
    //print("Bar Height: ");
    //println(barHeight); 
    if ( yValue > barValues[barIndex])
    {
      tts.speak("Pointer outside bar");
      wave.setAmplitude(0);
      println("Pointer outside bars");
      onoff = 0;    // Keep vibrator OFF (0) or ON (1)
      inten1 = 0;   //0 - 255
      inten2 = 0;   //0 - 255
      sweeptime_ms = 2;   //in ms
      repeatsweep = barIndex+1;    // no of times you want to repeat sweep within one cycle
      pulse_time_ms = 6000;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
      rest_ms = 2000;     // The No actuating time or resting in ms before starting next cycle
      vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";
      port.write(vib_cmd); 
      //barHeight=-1;
    }
    else if (barValues[barIndex] != barHeight)
    {   
      tts.speak(barNames[barIndex]+(int)barValues[barIndex]+"million");
      continuous_encoding(barHeight/1000);
      
      barHeight = barValues[barIndex];
      barH = (barHeight/100)*455;
      onoff = 1;    // Keep vibrator OFF (0) or ON (1)
      inten1 = (int)barH;   //0 - 255
      inten2 = 0;   //0 - 255
      sweeptime_ms = 2;   //in ms
      //repeatsweep = barIndex+1;    // no of times you want to repeat sweep within one cycle
      repeatsweep = (int)(barValues[barIndex]/10);
      println("repeatsweep:", repeatsweep, "\n");
      pulse_time_ms = 6000;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
      rest_ms = 2000;     // The No actuating time or resting in ms before starting next cycle
      vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";
      port.write(vib_cmd); 
      delay(100);
      println("Checkpoint");
    }  
  }
  else {
    wave.setAmplitude(0);
      println(" OFF ");
      onoff = 0;    // Keep vibrator OFF (0) or ON (1)
      inten1 = (int)barH;   //0 - 255
      inten2 = 0;   //0 - 255
      sweeptime_ms = 2;   //in ms
      repeatsweep = barIndex+1;    // no of times you want to repeat sweep within one cycle
      pulse_time_ms = 6000;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
      rest_ms = 2000;     // The No actuating time or resting in ms before starting next cycle
      vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";
      port.write(vib_cmd); 
    }   
}

void discrete_encoding(float barHeight)
{
    wave.setAmplitude(barHeight);
    delay(200);
    wave.setAmplitude(0);
    delay(200);  
}

void continuous_encoding(float barHeight)
{
    wave.setAmplitude(barHeight);
}
