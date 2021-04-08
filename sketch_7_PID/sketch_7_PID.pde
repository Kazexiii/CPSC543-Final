/**
 **********************************************************************************************************************
 * @file       sketch_2_Hello_Wall.pde
 * @author     Steve Ding, Colin Gallacher, Antoine Weill--Duflos
 * @version    V1.0.0
 * @date       09-February-2021
 * @brief      PID example with random position of a target
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */
 
 int device_num = 2; // you may need to change this to either 0, 1, or 2 (depending on your audio device #) to feel the vibrotactile information as audio for mode 1
 
  /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
import controlP5.*;

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.*;
import guru.ttslib.*;
import javax.sound.sampled.*;

Minim       minim;
AudioOutput out;
Oscil       wave;
Mixer.Info[] mixerInfo;

// Simple scatterplot compating income and life expectancy.
 
/* end library imports *************************************************************************************************/  


/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 

ControlP5 cp5;
import grafica.*;
GPlot plot;


/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           renderingForce                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerMeter                      = 4000.0;
float             radsPerDegree                       = 0.01745;

/* pantagraph link parameters in meters */
float             l                                   = 0.07;
float             L                                   = 0.09;


/* end effector radius in meters */
float             rEE                                 = 0.006;


/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);
PVector           oldangles                              = new PVector(0, 0);
PVector           diff                              = new PVector(0, 0);


/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                 = new PVector(0, 0); 

/* device graphical position */
PVector           deviceOrigin                        = new PVector(0, 0);

/* World boundaries reference */
final int         worldPixelWidth                     = 1000;
final int         worldPixelHeight                    = 650;

float x_m,y_m;

// used to compute the time difference between two loops for differentiation
long oldtime = 0;
// for changing update rate
int iter = 0;

/// PID stuff

float P = 0.0;
// for I
float I = 0;
float cumerrorx = 0;
float cumerrory = 0;
// for D
float oldex = 0.0f;
float oldey = 0.0f;
float D = 0;

//for exponential filter on differentiation
float diffx = 0;
float diffy = 0;
float buffx = 0;
float buffy = 0;
float smoothing = 0.80;

float xr = 0;
float yr = 0;

// checking everything run in less than 1ms
long timetaken= 0;

// set loop time in usec (note from Antoine, 500 is about the limit of my computer max CPU usage)
int looptime = 500;

/* graphical elements */
PShape pGraph, joint, endEffector;
PShape wall;
PShape target;
PFont f;

 PVector posEELast = new PVector(0, 0); 
Table table;

FWorld            world;
float             worldWidth                          = 23.5;  
float             worldHeight                         = 16.0; 

float             edgeTopLeftX                        = -1.0; 
float             edgeTopLeftY                        = -1.0; 
float             edgeBottomRightX                    = worldWidth; 
float             edgeBottomRightY                    = worldHeight;

float             gravityAcceleration                 = 980; //cm/s2
FBox                wall4;

HVirtualCoupling s;
float             pixelsPerCentimeter                 = 40.0;

PImage            haplyAvatar;
// 0 = navigation
// 1 = feeling the graph
int mode = 0;

/* end elements definition *********************************************************************************************/ 

/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 700);
  
  drawScatter();
     
  table = loadTable("data.csv", "header");
   
  /* GUI setup */
    smooth();
  cp5 = new ControlP5(this);
  cp5.addTextlabel("Prop")
                    .setText("Gain for P(roportional)")
                    .setPosition(0,0)
                    .setColorValue(color(255,0,0))
                    .setFont(createFont("Georgia",20))
                    ;
  cp5.addKnob("P")
               .setRange(0,2)
               .setValue(0)
               .setPosition(50,25)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL);
               
  cp5.addButton("ResetIntegrator")
     .setValue(0)
     .setPosition(5,360)
     .setSize(200,50)
     ;
  cp5.addButton("Somalia")
     .setValue(0)
     .setPosition(220,620)
     .setSize(200,50)
     ;
  cp5.addButton("UnitedStates")
     .setValue(0)
     .setPosition(430,620)
     .setSize(200,50)
     ;
  cp5.addButton("Mean")
     .setValue(0)
     .setPosition(850,620)
     .setSize(100,50)
     ;
     
//Textfield myTextfield;
PFont font = createFont("arial", 30);

  cp5.addTextfield("myTextfield")
  .setPosition(640,620)
  .setSize(200,50)
  .setFont(font);

  cp5.addTextlabel("countryName")
                    .setText("Type country name..")
                    .setPosition(635,600)
                    .setColorValue(color(255,0,0))
                    .setFont(createFont("Georgia",13))
                    ;  
  
  cp5.addButton("ResetDevice")
     .setValue(0)
     .setPosition(5,420)
     .setSize(200,50)
     ;
  cp5.addTextlabel("Deriv")
                    .setText("Gain for D(erivative)")
                    .setPosition(0,125)
                    .setColorValue(color(255,0,0))
                    .setFont(createFont("Georgia",20))
                    ;
  cp5.addKnob("D")
               .setRange(0,4)
               .setValue(0)
               .setPosition(50,150)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
               ; 
  cp5.addTextlabel("Deriv filt")
                    .setText("Exponential filter for Diff")
                    .setPosition(0,250)
                    .setColorValue(color(255,0,0))
                    .setFont(createFont("Georgia",18))
                    ;  
  cp5.addSlider("smoothing")
     .setPosition(5,275)
     .setSize(200,20)
     .setRange(0,1)
     .setValue(0.8)
     ;
  cp5.addTextlabel("Loop time")
                    .setText("Loop time")
                    .setPosition(0,300)
                    .setColorValue(color(255,0,0))
                    .setFont(createFont("Georgia",20))
                    ;  
  cp5.addSlider("looptime")
     .setPosition(5,330)
     .setWidth(200)
     .setRange(250,4000) // values can range from big to small as well
     .setValue(500)
     .setNumberOfTickMarks(16)
     .setSliderMode(Slider.FLEXIBLE)
     ;       
//Textfield myTextfield;
//PFont font = createFont("arial", 30);

  cp5.addTextfield("myTextfield")
  .setPosition(640,620)
  .setSize(200,50)
  .setFont(font);
  
  cp5.addButton("ResetDevice")
     .setValue(0)
     .setPosition(10,620)
     .setSize(200,50)
     ;
  
  /* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */ 
  haplyBoard          = new Board(this, "COM7", 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  pantograph          = new Pantograph();
  
  widgetOne.set_mechanism(pantograph);
  
  widgetOne.add_actuator(1, CCW, 2);
  widgetOne.add_actuator(2, CW, 1);
 
  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  
  widgetOne.device_set_parameters();
    
  /* visual elements setup */
  background(0);
  deviceOrigin.add(worldPixelWidth/2, 0);
  
  /* create pantagraph graphics */
  create_pantagraph();
  
  
  target = createShape(ELLIPSE, 0,0, 20, 20);
  target.setStroke(color(0));
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
    f = createFont("Arial",16,true); // STEP 2 Create Font
  
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();

  
  wall4                  = new FBox(15, 11);
  wall4.setPosition(14.25, 7);
  wall4.setStatic(true);
  wall4.setStrokeColor(205);
  wall4.setSensor(true);
  
  world.add(wall4);
  
  s                   = new HVirtualCoupling((1)); 
  s.h_avatar.setDensity(1); 
  s.h_avatar.setDamping(20);
  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 

  haplyAvatar = loadImage("../img/Haply_avatar.png"); 
  haplyAvatar.resize((int)(hAPI_Fisica.worldToScreen(1)), (int)(hAPI_Fisica.worldToScreen(1)));
  s.h_avatar.attachImage(haplyAvatar); 


  /* World conditions setup */
  world.setGravity((0.0), (1000.0)); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(.4);
  world.setEdgesFriction(0.5);
  world.draw();
  
  frameRate(baseFrameRate);
  
    /* setup simulation thread to run at 1kHz */ 
  thread("SimulationThread");
  
  minim = new Minim(this);
  mixerInfo = AudioSystem.getMixerInfo();  
  Mixer mixer = AudioSystem.getMixer(mixerInfo[device_num]);
  minim.setOutputMixer(mixer);
  out = minim.getLineOut();
  
  wave = new Oscil(200, 0.0f, Waves.SINE);
  wave.patch(out);
}
/* end setup section ***************************************************************************************************/

public void Mean(int theValue) {
  markerFromCoords(mean_income, mean_lifeExp);
}

public void Somalia(int theValue) {
  markerFromCoords(624, 58.7);
}

public void UnitedStates(int theValue) {
  markerFromCoords(53354, 79.1);
}

public void markerFromCoords(float x, float y)
{
  float[] screen = plot.getScreenPosAtValue(x, y);
  float s_x = screen[0];
  float s_y = screen[1];
  
  xr = (s_x - 500.661) / 300.61;
  yr = (s_y - 350.1734) / 298;  
}

public float[] haplyToScatter(float x, float y)
{
  xr = pow(10, 0.0173 * x + 3.5422);
  yr = -0.3495 * y + 91.516; 

  float[] var = {xr, yr};
  return var;
}

public float[] avatarToScatter(float x, float y)
{
  xr = pow(10, -0.0002 * x + 3.2382);
  yr = -0.0034 * y + 118.34; 

  float[] var = {xr, yr};
  return var;
}

float[] screen = new float[2];
float income = 0.0;
float lifeExp = 0.0;
float total_income = 0.0;
float total_lifeExp = 0.0;
float mean_income = 0.0;
float mean_lifeExp = 0.0;
String name = "";
boolean draw = false;

public void myTextfield(String theValue) {
  
  draw = false;
  theValue = theValue.toLowerCase();
  
  String[] data = loadStrings("data.csv");
  //float[] screen = new float[2];
  
  for (int i = 0; i < data.length - 1; i++)
  {
    if (data[i + 1].toLowerCase().contains(theValue)) 
    {
      String[] tokens = data[i+1].split(",");
  
      name = tokens[0];
      income  = Float.parseFloat(tokens[1]);   
      lifeExp = Float.parseFloat(tokens[2]); 
      
      screen = plot.getScreenPosAtValue(income, lifeExp);
      draw = true;
      break;
    }
  }
  
  float s_x = screen[0];
  float s_y = screen[1];
 
  xr = (s_x - 500.661) / 300.61;
  yr = (s_y - 350.1734) / 298;
  println(theValue);
}

public void RandomPosition(int theValue) {
      xr = 0;//-0.69; //random(-0.3,0.5);
    yr = 0;//0.22; //random(-0.5,0.5);
}

public void ResetIntegrator(int theValue) {
    cumerrorx= 0;
    cumerrory= 0;
}
public void ResetDevice(int theValue) {
    widgetOne.device_set_parameters();
    P = 0;
    I = 0;
    D = 0;
    widgetOne.set_device_torques(new float[]{0, 0});
    widgetOne.device_write_torques();
}


/* Keyboard inputs *****************************************************************************************************/

/// Antoine: this is specific to qwerty keyboard layout, you may want to adapt

void keyPressed() {
  if (key == '1')
  {
    mode = 1;
    thread("SimulationThread");
  }
  else if (key == '0')
  {
    mode = 0;
    thread("SimulationThread");
  }
  else if (key == '2')
  {
    mode = 2;
    SimulateFric st = new SimulateFric();
    scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
  }
}

float[] distances = new float[2];
  
/* draw section ********************************************************************************************************/
void draw(){
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  if(renderingForce == false){
        background(255); 
    world.draw();
    
    //the PID snapper only exists with modes 0 and 1
    if (mode != 2)
      update_animation(angles.x*radsPerDegree, angles.y*radsPerDegree, posEE.x, posEE.y);  
    
    plot.beginDraw();
  //plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.drawGridLines(GPlot.BOTH);
  plot.drawPoints();
  plot.drawLabels();
  plot.setFontSize(16);
  
  if (draw == true) {
    plot.drawAnnotation("Country: " + name, 80794, 55, CENTER, CENTER);
    plot.drawAnnotation("Income: " + income, 80794, 53, CENTER, CENTER);
    plot.drawAnnotation("Life Expectancy: " + lifeExp, 80794, 51, CENTER, CENTER);
  }
  plot.endDraw();
  
  if (mode == 0)
    wave.setAmplitude(0.0f);
  
  else if (mode == 1)
  {
     //distances[0] = 0.0;
     distances[1] = 0.0;
   
     float[] current_pos = haplyToScatter(posEE.x * 1000, posEE.y * 1000);
     
      for (int row = 0; row < table.getRowCount(); row++) {
      float income = table.getFloat(row, "income");
      float health = table.getFloat(row, "health");
      
      //distances[0] = distances[0] + abs(current_pos[0] - income);
      distances[1] = distances[1] + abs(current_pos[1] - health);
    }
    
    //println(distances[0] + ", " + distances[1]);
    float amplitude = 1 / pow(distances[1], 2) * 1000000;
    wave.setAmplitude(amplitude);
  }
  
  else if (mode == 2)
  {
     distances[0] = 0.0;
     distances[1] = 0.0;
   
     float[] current_pos = avatarToScatter(posEE.x * 1000, posEE.y * 1000);
     
     //println(current_pos[0] + ", " + current_pos[1]);
     
      for (int row = 0; row < table.getRowCount(); row++) {
      float income = table.getFloat(row, "income");
      float health = table.getFloat(row, "health");
      
      //distances[0] = distances[0] + abs(current_pos[0] - income);
      distances[1] = distances[1] + abs(current_pos[1] - health);  
    }
      float damping = (1 / pow(distances[1], 2) * 1000000000) + 200;
      println(damping);  
      s.h_avatar.setDamping(damping);
  }
  
  }
}

int k = 1 * 10^6;
/* end draw section ****************************************************************************************************/

int noforce = 0;
long timetook = 0;
long looptiming = 0;
/* simulation section **************************************************************************************************/
public void SimulationThread(){

while(1==1) {
  
  if (mode == 2)
    return;

    long starttime = System.nanoTime();
    long timesincelastloop=starttime-timetaken;
    iter+= 1;
    // we check the loop is running at the desired speed (with 10% tolerance)
    if(timesincelastloop >= looptime*1000*1.1) {
      float freq = 1.0/timesincelastloop*1000000.0;
      //  println("caution, freq droped to: "+freq + " kHz");
    }
    else if(iter >= 1000) {
      float freq = 1000.0/(starttime-looptiming)*1000000.0;
     //  println("loop running at "  + freq + " kHz");
       iter=0;
       looptiming=starttime;
    }
    
    timetaken=starttime;
    
    renderingForce = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
      
      noforce = 0;
      angles.set(widgetOne.get_device_angles());

      
      // **************************************************************************************
      
      //println(xr + ", " + yr);
      //normalizeData(); 
      //println(mouseX + ", " + mouseY);
      
      // **************************************************************************************

    
      posEE.set(widgetOne.get_device_position(angles.array()));
      posEE.set(device_to_graphics(posEE)); 
      x_m = xr*300; 
      y_m = yr*300+350;//mouseY;
      
 // Torques from difference in endeffector and setpoint, set gain, calculate force
      float xE = pixelsPerMeter * posEE.x;
      float yE = pixelsPerMeter * posEE.y;
      long timedif = System.nanoTime()-oldtime;
      
      float dist_X = x_m-xE;
      cumerrorx += dist_X*timedif*0.000000001;
      float dist_Y = y_m-yE;
      cumerrory += dist_Y*timedif*0.000000001;
      //println(dist_Y*k + " " +dist_Y*k);
      // println(timedif);
      if(timedif > 0) {
        buffx = (dist_X-oldex)/timedif*1000*1000;
        buffy = (dist_Y-oldey)/timedif*1000*1000;            

        diffx = smoothing*diffx + (1.0-smoothing)*buffx;
        diffy = smoothing*diffy + (1.0-smoothing)*buffy;
        oldex = dist_X;
        oldey = dist_Y;
        oldtime=System.nanoTime();
      }
    
    // Forces are constrained to avoid moving too fast
  
      fEE.x = constrain(P*dist_X,-4,4) + constrain(I*cumerrorx,-4,4) + constrain(D*diffx,-8,8);

      
      fEE.y = constrain(P*dist_Y,-4,4) + constrain(I*cumerrory,-4,4) + constrain(D*diffy,-8,8); 


      if(noforce==1)
      {
        fEE.x=0.0;
        fEE.y=0.0;
      }
    widgetOne.set_device_torques(graphics_to_device(fEE).array());
    //println(f_y);
      /* end haptic wall force calculation */
      
    }
    
    
    
    widgetOne.device_write_torques();
  
  
    renderingForce = false;
    long timetook=System.nanoTime()-timetaken;
    if(timetook >= 1000000) {
   // println("Caution, process loop took: " + timetook/1000000.0 + "ms");
    }
    else {
      while(System.nanoTime()-starttime < looptime*1000) {
      //println("Waiting");
      }
    }
    
  }
}
/* simul fric section **********/
class SimulateFric implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    if (mode == 0)
      return;
    if (mode == 1)
      return;
      
    renderingForce = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
      posEE.set(widgetOne.get_device_position(angles.array()));
      posEE.set(posEE.copy().mult(200));  
    }

    s.setToolPosition(edgeTopLeftX+worldWidth/2-(posEE).x, edgeTopLeftY+(posEE).y-7); 
   
    s.updateCouplingForce();
    fEE.set(-s.getVirtualCouplingForceX(), s.getVirtualCouplingForceY());
    fEE.div(100000); //dynes to newtons
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
  
    world.step(1.0f/1000.0f);
  
    renderingForce = false;
  }
}
/* end simulation section **********************************************************************************************/


void drawScatter()
{
  // Load the cvs dataset. 
  // The file has the following format: 
  // country,income,health,population
  // Central African Republic,599,53.8,4900274
  // ...
  Table table = loadTable("data.csv", "header");

  // Save the data in one GPointsArray and calculate the point sizes
  GPointsArray points = new GPointsArray();
  float[] pointSizes = new float[table.getRowCount()];
  
  for (int row = 0; row < table.getRowCount(); row++) {
    String country = table.getString(row, "country");
    float income = table.getFloat(row, "income");
    float health = table.getFloat(row, "health");
    int population = table.getInt(row, "population");
    points.add(income, health, country);
    
    total_income += income;
    total_lifeExp += health;
    
    // The point area should be proportional to the country population
    // population = pi * sq(diameter/2) 
    pointSizes[row] = 2 * sqrt(population/(200000 * PI));
  }
  
  mean_income = total_income / pointSizes.length;
  mean_lifeExp = total_lifeExp / pointSizes.length;

  // Create the plot
  plot = new GPlot(this);
  plot.setDim(650, 500);
  plot.setPos(200, 0);
  plot.setTitleText("Life expectancy connection to average income");
  plot.getXAxis().setAxisLabelText("Personal income ($/year)");
  plot.getYAxis().setAxisLabelText("Life expectancy (years)");
  plot.setLogScale("x");
  plot.setPoints(points);
  plot.setPointSizes(pointSizes);
  plot.activatePointLabels();
  //plot.activatePanning();
  //plot.activateZooming(1.1, CENTER, CENTER);
}


/* end simulation section **********************************************************************************************/


/* helper functions section, place helper functions here ***************************************************************/
void create_pantagraph(){
  float lAni = pixelsPerMeter * l;
  float LAni = pixelsPerMeter * L;
  float rEEAni = pixelsPerMeter * rEE;
  
  pGraph = createShape();
  pGraph.beginShape();
  pGraph.fill(255);
  pGraph.stroke(0);
  pGraph.strokeWeight(2);
  
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  pGraph.endShape(CLOSE);
  
  joint = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, rEEAni, rEEAni);
  joint.setStroke(color(0));
  
  endEffector = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, 2*rEEAni, 2*rEEAni);
  endEffector.setStroke(color(0));
  strokeWeight(5);
  
}


PShape create_wall(float x1, float y1, float x2, float y2){
  x1 = pixelsPerMeter * x1;
  y1 = pixelsPerMeter * y1;
  x2 = pixelsPerMeter * x2;
  y2 = pixelsPerMeter * y2;
  
  return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y+y2);
}




void update_animation(float th1, float th2, float xE, float yE){
  background(255);
    pushMatrix();
  float lAni = pixelsPerMeter * l;
  float LAni = pixelsPerMeter * L;
  
  xE = pixelsPerMeter * xE;
  yE = pixelsPerMeter * yE;
  
  th1 = 3.14 - th1;
  th2 = 3.14 - th2;
    
  pGraph.setVertex(1, deviceOrigin.x + lAni*cos(th1), deviceOrigin.y + lAni*sin(th1));
  pGraph.setVertex(3, deviceOrigin.x + lAni*cos(th2), deviceOrigin.y + lAni*sin(th2));
  pGraph.setVertex(2, deviceOrigin.x + xE, deviceOrigin.y + yE);
  
  shape(pGraph);
  shape(joint);
  float[] coord;
  
  
  translate(xE, yE);
  shape(endEffector);
  popMatrix();
  arrow(xE,yE,fEE.x,fEE.y);
  textFont(f,16);                  // STEP 3 Specify font to be used
  fill(0);                         // STEP 4 Specify font color 
 
  x_m = xr*300+500; 
      //println(x_m + " " + mouseX);")
      y_m = yr*300+350;//mouseY;
  pushMatrix();
  translate(x_m, y_m);
  shape(target);
  popMatrix();
  
}


PVector device_to_graphics(PVector deviceFrame){
  return deviceFrame.set(-deviceFrame.x, deviceFrame.y);
}


PVector graphics_to_device(PVector graphicsFrame){
  return graphicsFrame.set(-graphicsFrame.x, graphicsFrame.y);
}

void arrow(float x1, float y1, float x2, float y2) {
    x2=x2*10.0;
  y2=y2*10.0;
  x1=x1+500;
  x2=-x2+x1;
  y2=y2+y1;

  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
} 

/* end helper functions section ****************************************************************************************/
