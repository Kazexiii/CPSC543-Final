/**
 **********************************************************************************************************************
 * @file       sketch_4_Wall_Physics.pde
 * @author     Steve Ding, Colin Gallacher
 * @version    V4.1.0
 * @date       08-January-2021
 * @brief      wall haptic example using 2D physics engine 
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */



/* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
import org.gicentre.utils.stat.*;
  
import processing.sound.*;


/* end library imports *************************************************************************************************/  



/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 



/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           renderingForce                      = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerCentimeter                 = 40.0;

/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                = new PVector(0, 0); 



/* World boundaries in centimeters */
FWorld            world;
float             worldWidth                          = 23.5;  
float             worldHeight                         = 16.0; 

float             edgeTopLeftX                        = -1.0; 
float             edgeTopLeftY                        = -1.0; 
float             edgeBottomRightX                    = worldWidth; 
float             edgeBottomRightY                    = worldHeight;

String k = "Rendering Off" ;


/* Initialization of wall */
FBox              wall, wall2, wall3, wall4, wall5, wall6, wall7, wall8, wall9,wall10, wall11, wall12; 
FCircle           circle1,circle2;
FBlob             blob1;


/* Initialization of virtual tool */
HVirtualCoupling  s;
PImage            haplyAvatar,pac2;

/* end elements definition *********************************************************************************************/ 


private float[] barValues = {7, 4, 8, 0.5, 0.1}; // barchart values
BarChart barChart;

//SoundFile sound; 


/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(900, 600);
  //sound = new SoundFile(this, "beep-03.wav");
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
  haplyBoard          = new Board(this, "COM4", 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  pantograph          = new Pantograph();
  
  widgetOne.set_mechanism(pantograph);

  widgetOne.add_actuator(1, CCW, 2);
  widgetOne.add_actuator(2, CW, 1);
 
  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  
  
  widgetOne.device_set_parameters();
  
  
  /* 2D physics scaling and world creation */
  hAPI_Fisica.init(this); 
  hAPI_Fisica.setScale(pixelsPerCentimeter); 
  world               = new FWorld();
  
  
  /* creation of wall */
  wall                   = new FBox(35, 0.1);
  wall.setPosition(7, 13.1);
  wall.setStatic(true);
  wall.setFill(0,0,0);
  world.add(wall);
 // System.out.println(edgeTopLeftX+worldWidth); 
  //System.out.println(edgeTopLeftY+2*worldHeight); 
  
  //wall2                   = new FBox(3, 9.1);
  //wall2.setPosition(2.3, 8.5);
  //wall2.setStatic(true);
  //wall2.setFill(0,0,0);
  //wall2.setName("1");
  //world.add(wall2);
  
  
  //wall3                   = new FBox(3, 5.2);
  //wall3.setPosition(6.84, 10.5);
  //wall3.setStatic(true);
  //wall3.setFill(0,0,0);
  //wall3.setName("1");
  //world.add(wall3);
  
  
  //wall4                  = new FBox(3, 10.3);
  //wall4.setPosition(11.35, 7.8);
  //wall4.setStatic(true);
  //wall4.setFill(0,0,0);
  //wall4.setName("1");
  //world.add(wall4);


  //wall5                  = new FBox(3, 0.7);
  //wall5.setPosition(15.9, 12.8);
  //wall5.setStatic(true);
  //wall5.setFill(0,0,0);
  //wall5.setName("1");
  //world.add(wall5);
  
  
  
  //wall6                  = new FBox(3, 0.18);
  //wall6.setPosition(20.45, 13.05);
  //wall6.setStatic(true);
  //wall6.setFill(0,0,0);
  //wall6.setName("1");
  //world.add(wall6);
  
  
  //  wall7                   = new FBox(3, 9.1);
  //wall7.setPosition(2.3, 8.5);
  //wall7.setStatic(true);
  //wall7.setFill(0,0,0);
  //wall7.setName("2");
  //world.add(wall7);
  
  
  //wall8                   = new FBox(3, 5.2);
  //wall8.setPosition(6.84, 10.5);
  //wall8.setStatic(true);
  //wall8.setFill(0,0,0);
  //wall8.setName("2");
  //world.add(wall8);
  
  
  //wall9                  = new FBox(3, 10.3);
  //wall9.setPosition(11.35, 7.8);
  //wall9.setStatic(true);
  //wall9.setFill(0,0,0);
  //wall9.setName("2");
  //world.add(wall9);


  //wall10                  = new FBox(3, 0.7);
  //wall10.setPosition(15.9, 12.8);
  //wall10.setStatic(true);
  //wall10.setFill(0,255,0);
  //wall10.setName("2");
  //world.add(wall10);
  
  
  
  //wall11                  = new FBox(3, 0.18);
  //wall11.setPosition(20.45, 13.05);
  //wall11.setStatic(true);
  //wall11.setFill(0,0,0);
  //wall11.setName("2");
  //world.add(wall11);


  
      
  
  /* Haptic Tool Initialization */
  s                   = new HVirtualCoupling((1)); 
  s.h_avatar.setDensity(4);  
  s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 
 
  
  /* If you are developing on a Mac users must update the path below 
   * from "../img/Haply_avatar.png" to "./img/Haply_avatar.png" 
   */
  haplyAvatar = loadImage("../img/Haply_avatar.png"); 
  haplyAvatar.resize((int)(hAPI_Fisica.worldToScreen(1)), (int)(hAPI_Fisica.worldToScreen(1)));
  s.h_avatar.attachImage(haplyAvatar); 



  /* world conditions setup */
  world.setGravity((0.0), (1000.0)); //1000 cm/(s^2)
  world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
  world.setEdgesRestitution(.4);
  world.setEdgesFriction(0.5);
  
  
  barChart = new BarChart(this);
  barChart.setData(barValues);
  
  barChart.setMinValue(0);
  barChart.setMaxValue(10);
  
  barChart.showValueAxis(true);
  barChart.showCategoryAxis(true); 
  barChart.setBarGap(60);
  barChart.setAxisColour(color(0,0,0));
  barChart.setAxisLabelColour(color(0,0,0));
  barChart.setAxisValuesColour(color(0,0,0));

  
  world.draw();
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  

  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
}
/* end setup section ***************************************************************************************************/



/* draw section ********************************************************************************************************/
void draw(){
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  
  if(renderingForce == false){
    background(255);
    world.draw();
    barChart.draw(15,-10, width - 30, height - 50);
    textSize(13);
    fill (color(0,0,0));
    text("Please click on this window and press keys 1 or 2 to change the rendering mode.", 200, 60);
    fill (color(255,0,0));
    text(k, 200, 80);
    
  }
}
/* end draw section ****************************************************************************************************/

void keyPressed() {
  if (key == '1') {
    
    
      wall2                   = new FBox(3, 9.1);
      wall2.setPosition(2.3, 8.5);
      wall2.setStatic(true);
      wall2.setFill(0,0,0);
      world.add(wall2);
      
      
      wall3                   = new FBox(3, 5.2);
      wall3.setPosition(6.84, 10.5);
      wall3.setStatic(true);
      wall3.setFill(0,0,0);
      world.add(wall3);
      
      
      wall4                  = new FBox(3, 10.3);
      wall4.setPosition(11.35, 7.8);
      wall4.setStatic(true);
      wall4.setFill(0,0,0);
      world.add(wall4);
    
    
      wall5                  = new FBox(3, 0.7);
      wall5.setPosition(15.9, 12.8);
      wall5.setStatic(true);
      wall5.setFill(0,0,0);
      world.add(wall5);
      
      
      
      wall6                  = new FBox(3, 0.18);
      wall6.setPosition(20.45, 13.05);
      wall6.setStatic(true);
      wall6.setFill(0,0,0);
      world.add(wall6);
      
      world.remove(wall7);
      world.remove(wall8);
      world.remove(wall9);
      world.remove(wall10);
      world.remove(wall11);
      k = "Mode 1"; 

   
  }
  if (key == '2') 
  {
      wall7                   = new FBox(3, 9.1);
      wall7.setPosition(2.3, 8.5);
      wall7.setStatic(true);
      wall7.setSensor(true);
      wall7.setFill(0,0,0);
      world.add(wall7);
  
  
      wall8                   = new FBox(3, 5.2);
      wall8.setPosition(6.84, 10.5);
      wall8.setStatic(true);
      wall8.setSensor(true);
      wall8.setFill(0,0,0);
      world.add(wall8);
  
  
      wall9                  = new FBox(3, 10.3);
      wall9.setPosition(11.35, 7.8);
      wall9.setSensor(true);
      wall9.setStatic(true);
      wall9.setFill(0,0,0);
      world.add(wall9);
    

      wall10                  = new FBox(3, 0.7);
      wall10.setPosition(15.9, 12.8);
      wall10.setStatic(true);
      wall10.setSensor(true);
      wall10.setFill(0,0,0);
      world.add(wall10);
  
  
  
      wall11                  = new FBox(3, 0.18);
      wall11.setPosition(20.45, 13.05);
      wall11.setStatic(true);
      wall11.setSensor(true);
      wall11.setFill(0,0,0);
      world.add(wall11);
      
      //wall12                  = new FBox(30, 30);
      //wall12.setPosition(10, 1);
      //wall12.setStatic(true);
      //wall12.setSensor(true);
      ////wall12.setFill(0,255,0);
      //wall12.setNoFill();
      //world.add(wall12);
      
      
      //blob1                  = new FBlob();
      //blob1.setAsCircle(10, 0, 40, 30);
      //blob1.setStroke(0);
      //blob1.setStrokeWeight(2);
      //blob1.setFriction(700);
      //blob1.setDensity(700);
      ////f.setDensity(30);
      //blob1.setNoFill();
      //world.add(blob1);
      
      world.remove(wall2);
      world.remove(wall3);
      world.remove(wall4);
      world.remove(wall5);
      world.remove(wall6);
      k = "Mode 2"; 

  }
  }

/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    
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
    
    
    if (s.h_avatar.isTouchingBody(wall7) || s.h_avatar.isTouchingBody(wall8) || s.h_avatar.isTouchingBody(wall9) || s.h_avatar.isTouchingBody(wall10) || s.h_avatar.isTouchingBody(wall11)) {
      s.h_avatar.setDamping(700);

      
    }else {
      s.h_avatar.setDamping(0);
      
    }
    
   
    
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
  
    world.step(1.0f/1000.0f);
  
    renderingForce = false;
  }
}
/* end simulation section **********************************************************************************************/



/* helper functions section, place helper functions here ***************************************************************/

/* end helper functions section ****************************************************************************************/
