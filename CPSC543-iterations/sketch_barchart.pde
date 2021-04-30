import org.gicentre.utils.stat.*;  
import processing.serial.*;

Serial myPort;  // Create object from Serial class

// --------------------- Sketch-wide variables ----------------------

BarChart barChart;
PFont titleFont,smallFont;

// ------------------------ Initialisation --------------------------

// Initialises the data and bar chart.
void setup()
{
  size(800,500);
  
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  
  smooth();

  
  titleFont = loadFont("SansSerif.plain-14.vlw");
  smallFont = loadFont("SansSerif.plain-14.vlw");
  textFont(smallFont);

  barChart = new BarChart(this);
  barChart.setData(new float[] {6,4,10,2,1});
  barChart.setBarLabels(new String[] {"A","B","C","D","E"});
  barChart.setMinValue(0);
  barChart.setBarColour(color(200,80,80,100));
  barChart.setBarGap(20); 
  barChart.setValueFormat("$###,###");
  barChart.showValueAxis(true); 
  barChart.showCategoryAxis(true); 
}



void draw() {
  background(255);
   if (mousePressed == true){
     if (pmouseX >= 36 & pmouseX <=169)
       {
         myPort.write('A');
         print("A\n");
       }
     else if (pmouseX >= 190 & pmouseX <= 322)
       {
         myPort.write('B');
         print("B\n");
       }
     else if (pmouseX >= 344 & pmouseX <= 475)
       {
         myPort.write('C');
         print("C\n");
       }
     else if (pmouseX >= 497 & pmouseX <= 629)
       {
         myPort.write('D');
         print("D\n");
       }
     else if (pmouseX >= 650 & pmouseX <= 781)
       {
         myPort.write('E');
         print("E\n");
       }
  }
  else{
    myPort.write('Z');
  }
      
  barChart.draw(10,10,width-20,height-20);
  fill(120);
  textFont(titleFont);
  text("Income per person, United Kingdom", 70,30);
  float textHeight = textAscent();
  text("Gross domestic product measured in inflation-corrected $US", 70,30+textHeight);
  
  print("X:",pmouseX, "Y:",500-pmouseY,"\n");
  print("------\n");
}
