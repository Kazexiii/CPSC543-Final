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


/* Initialization of wall */
FBox              wall;//, wall2, wall3, wall4, wall5, wall6, wall7, wall8, wall9,wall10; 
FCircle           c1,c2,c3,c4,c5,c6,c7,c8,c9,c10;
FBlob             blob1;


/* Initialization of virtual tool */
HVirtualCoupling  s;
PImage            haplyAvatar,pac2;

/* end elements definition *********************************************************************************************/ 


private float[] xValues = {0.66, 0.4, 0.56, 0.5, 0.5, 0.2, 0.1, 0.4, 0.4, 0.2, 0.25, 0.22, 0.22, 0.3, 0.28, 0.25, 0.29, 0.66};
private float[] yValues = {0.56, 0.4, 0.60, 0.5, 0.3, 0.3, 0.23, 0.3, 0.33, 0.23, 0.4,  0.4, 0.46, 0.44,  0.42, 0.46,  0.42, 0.56 };// barchart values

private float[] sizes = {50,20,40,10,20, 5,7,9, 3, 3.2, 50, 10, 7, 2, 8, 4, 12, 6};
BarChart barChart;
XYChart scatterplot;

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
  
  //wall2                   = new FBox(3, 9.9);
  //wall2.setPosition(2.4, 8.1);
  //wall2.setStatic(true);
  //wall2.setFill(0,0,0);
  //world.add(wall2);
  
  
  //wall3                   = new FBox(3, 5);
  //wall3.setPosition(6.9, 10.4);
  //wall3.setStatic(true);
  //wall3.setFill(0,0,0);
  //world.add(wall3);
  
  
  //wall4                  = new FBox(3, 9.8);
  //wall4.setPosition(11.424, 8.1);
  //wall4.setStatic(true);
  //wall4.setFill(0,0,0);
  //world.add(wall4);


  //wall5                  = new FBox(3, 6.5);
  //wall5.setPosition(15.9, 9.8);
  //wall5.setStatic(true);
  //wall5.setFill(0,0,0);
  //world.add(wall5);
  
  
  
  //wall6                  = new FBox(3, 3.9);
  //wall6.setPosition(20.45, 11.1);
  //wall6.setStatic(true);
  //wall6.setFill(0,0,0);
  //world.add(wall6);
  
 c1                = new FCircle(2.5);
  c1.setPosition(7, 6.6);
  c1.setStatic(true);
  c1.setNoFill();
  c1.setNoStroke(); 
  c1.setSensor(true);
  world.add(c1);
  
  
  c2                = new FCircle(1.2);
  c2.setPosition(6.2, 6.6);
  c2.setStatic(true);
  c2.setNoFill();
  c2.setNoStroke(); 
  c2.setSensor(true);
  world.add(c2);

  c3                = new FCircle(1.0);
  c3.setPosition(6.2, 5.6);
  c3.setStatic(true);
  c3.setNoFill();
  c3.setNoStroke(); 
  c3.setSensor(true);
  world.add(c3);
  
  c4                = new FCircle(0.7);
  c4.setPosition(7, 5.6);
  c4.setStatic(true);
  c4.setNoFill();
  c4.setNoStroke(); 
  c4.setSensor(true);
  world.add(c4);
  
    c5               = new FCircle(1.1);
  c5.setPosition(7.7, 6.2);
  c5.setStatic(true);
  c5.setNoFill();
  c5.setNoStroke(); 
  c5.setSensor(true);
  world.add(c5);
  
  
      c6               = new FCircle(1.2);
  c6.setPosition(7.9, 6.2);
  c6.setStatic(true);
  c6.setNoFill();
  c6.setNoStroke(); 
  c6.setSensor(true);
  world.add(c6);
  
  
        c7               = new FCircle(2.5);
  c7.setPosition(16.9, 4);
  c7.setStatic(true);
  c7.setNoFill();
  c7.setNoStroke(); 
  c7.setSensor(true);
  world.add(c7);
  
  
          c8               = new FCircle(0.8);
  c8.setPosition(16.9, 4);
  c8.setStatic(true);
  c8.setNoFill();
  c8.setNoStroke(); 
  c8.setSensor(true);
  world.add(c8);
  
  

      
      
  
  /* Haptic Tool Initialization */
  s                   = new HVirtualCoupling((1)); 
  s.h_avatar.setDensity(4);  
  s.h_avatar.setSensor(false);
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
  
  
  scatterplot = new XYChart(this);
  scatterplot.setData(xValues,yValues);
  
  //scatter.setMinValue(0);
  //scatter.setMaxValue(1);
  
  //scatterplot.showValueAxis(true);
  //scatter.showCategoryAxis(true); 
  //barChart.setBarGap(60);
  scatterplot.showXAxis(true);
  scatterplot.showYAxis(true);
  scatterplot.setMinY(0);
  scatterplot.setMaxY(0.8);
  scatterplot.setMinX(0);
  scatterplot.setAxisColour(color(0,0,0));
  scatterplot.setAxisLabelColour(color(0,0,0));
  scatterplot.setAxisValuesColour(color(0,0,0));
  scatterplot.setPointSize(sizes,100);
  scatterplot.setPointColour(color(180,50,50,100));

  
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
    scatterplot.draw(15,-10, width - 90, height - 50);
    textSize(13);
  }
}
/* end draw section ****************************************************************************************************/



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
   
    //System.out.println(s.getToolPositionX());
    
    //if (s.getToolPositionX() <= -0.3 || s.getToolPositionX() >= 15.0){
    //sound.play();
   
    
    //}else{
    //sound.stop();
    //}
    
    s.updateCouplingForce();
    fEE.set(-s.getVirtualCouplingForceX(), s.getVirtualCouplingForceY());
    fEE.div(100000); //dynes to newtons
    
    
    
    //if (s.h_avatar.isTouchingBody(c1)){   
     //s.h_avatar.adjustPosition(0,0.15);  
     // s.h_avatar.setVelocity(1,10); 
     //s.h_avatar.setForce(0,0.0001);
     //s.h_avatar.setPosition(10,10);
      
    //}
    
    // if (s.h_avatar.isTouchingBody(c2)){   
    // s.h_avatar.adjustPosition(-0.08,0);  
      
    //}
    
     
     
    // if (s.h_avatar.isTouchingBody(c1) && s.h_avatar.getY() >= 6.6){   
    // s.h_avatar.adjustPosition(0.1,-0.3);  
   
      
    //}else if (s.h_avatar.isTouchingBody(c1) && s.h_avatar.getY() < 6.6){
    //  s.h_avatar.adjustPosition(0.1,0.3); 

    //}else if (s.h_avatar.isTouchingBody(c1) && s.h_avatar.getX() < 7){
    //  s.h_avatar.adjustPosition(0.4,0.3); 
      
    //}else if (s.h_avatar.isTouchingBody(c1) && s.h_avatar.getX() >= 7){
    //  s.h_avatar.adjustPosition(-0.4,-0.1); 
    //}

    if (s.h_avatar.isTouchingBody(c1)){
    
        fEE.x = random(-1.5, 1.5);
        fEE.y = random(-1.5, 1.5);
    }
    if (s.h_avatar.isTouchingBody(c7)){
    
        fEE.x = random(-1, 1);
        fEE.y = random(-1, 1);
    }
    
    
    // if (s.h_avatar.isTouchingBody(c3)){   
    // s.h_avatar.adjustPosition(0.01,0);  
      
    //}
    
    // if (s.h_avatar.isTouchingBody(c4) && s.h_avatar.getY() > 5.6){   
    // s.h_avatar.adjustPosition(0,0.08);  
      
    //}
    
    // if (s.h_avatar.isTouchingBody(c5)){   
    // s.h_avatar.adjustPosition(0,0.08);  
      
    //}
    
    //if (s.h_avatar.isTouchingBody(c6) && s.h_avatar.getY() >= 6.2 ){   
    // s.h_avatar.adjustPosition(0,-0.12);  
      
    //}else if (s.h_avatar.isTouchingBody(c6) && s.h_avatar.getY() < 6.2 ){
      
    //s.h_avatar.adjustPosition(0,0.1);  
    //}
   
    
    //if (s.h_avatar.isTouchingBody(c7) && s.h_avatar.getY() > 4){   
    // s.h_avatar.adjustPosition(0.1,-0.17);  
   
      
    //}else if (s.h_avatar.isTouchingBody(c7) && s.h_avatar.getY() <= 4){
    //  s.h_avatar.adjustPosition(0.1,0.17); 

    //}else if (s.h_avatar.isTouchingBody(c7) && s.h_avatar.getX() <= 16.9){
    //  s.h_avatar.adjustPosition(0.5,0); 

    //}else if (s.h_avatar.isTouchingBody(c7) && s.h_avatar.getX() > 16.9){
    //  s.h_avatar.adjustPosition(-0.5,0); 

    //}
    

    
    
    // if (s.h_avatar.isTouchingBody(c8) && s.h_avatar.getY() > 4){   
    // s.h_avatar.adjustPosition(0,-0.1);  
   
      
    //}else if (s.h_avatar.isTouchingBody(c8) && s.h_avatar.getY() <= 4){
    //  s.h_avatar.adjustPosition(0,0.1); 

    //}
    
    
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
  
    world.step(1.0f/1000.0f);
  
    renderingForce = false;
  }
}
/* end simulation section **********************************************************************************************/



/* helper functions section, place helper functions here ***************************************************************/

/* end helper functions section ****************************************************************************************/
