import SimpleOpenNI.*;
import processing.opengl.*;
import processing.serial.*;

SimpleOpenNI kinect;
Serial myPort;

// NITE
XnVSessionManager sessionManager;
XnVPointControl pointControl;
XnVCircleDetector circleDetector;

// Font for text on screen
PFont font;

// Variable to define different modes
int mode = 0;

// Variables for Hand Detection
boolean handsTrackFlag = true;
PVector screenHandVec = new PVector();
PVector handVec = new PVector();
ArrayList<PVector>    handVecList = new ArrayList<PVector>();
int handVecListSize = 30;

// Variables for Channel and Volume Control
float rot;
float prevRot;
float rad;
float angle;
PVector centerVec = new PVector();
PVector screenCenterVec = new PVector();
int changeChannel;
int channelTime;

void setup()
{
  // Simple-openni object
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  // enable depthMap generation, hands + gestures
  kinect.enableDepth();
  kinect.enableGesture();
  kinect.enableHands();

  // setup NITE 
  sessionManager = kinect.createSessionManager("Wave", "RaiseHand");

  // Setup NITE.s Hand Point Control
  pointControl = new XnVPointControl();
  pointControl.RegisterPointCreate(this);
  pointControl.RegisterPointDestroy(this);
  pointControl.RegisterPointUpdate(this);

  // Setup NITE's Circle Detector
  circleDetector = new XnVCircleDetector();  
  circleDetector.RegisterCircle(this); 
  circleDetector.RegisterNoCircle(this); 

  // Add the two to the session  
  sessionManager.AddListener(circleDetector);
  sessionManager.AddListener(pointControl);

  // Set the sketch size to match the depth map
  size(kinect.depthWidth(), kinect.depthHeight()); 
  smooth();

  // Initialize Font
  font = loadFont("SansSerif-12.vlw");
  
  //Initialize Serial Communication
  String portName = Serial.list()[0]; // This gets the first port on your computer.
  myPort = new Serial(this, portName, 9600);
}

////////////////////////////////////////////////////////////////////////////////////////////

// XnVPointControl callbacks

void onPointCreate(XnVHandPointContext pContext)
{
  println("onPointCreate:");
  handsTrackFlag = true;
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
  handVecList.clear();
  handVecList.add(handVec.get());
}

void onPointDestroy(int nID)
{
  println("PointDestroy: " + nID);
  handsTrackFlag = false;
}

void onPointUpdate(XnVHandPointContext pContext)
{
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
  handVecList.add(0, handVec.get());
  if (handVecList.size() >= handVecListSize)
  { // remove the last point 
    handVecList.remove(handVecList.size()-1);
  }
}

// XnVCircleDetector callbacks

void onCircle(float fTimes, boolean bConfident, XnVCircle circle)
{
  println("onCircle: " + fTimes + " , bConfident=" + bConfident); 
  rot = fTimes;
  angle = (fTimes % 1.0f) * 2 * PI - PI/2 ;
  centerVec.set(circle.getPtCenter().getX(), circle.getPtCenter().getY(), handVec.z);
  kinect.convertRealWorldToProjective(centerVec, screenCenterVec);
  rad = circle.getFRadius();
  mode = 1;
}

void onNoCircle(float fTimes, int reason)
{
  println("onNoCircle: " + fTimes + " , reason= " + reason);  
  mode = 0;
}

// Draw and other Functions

void draw()
{
  background(0);
  // Update Kinect data
  kinect.update();
  // update NITE
  kinect.update(sessionManager);

  // draw depthImageMap
  image(kinect.depthImage(), 0, 0);

  // Switch between modes
  switch(mode) {
    case 0: // Waiting Mode
    checkSpeed(); // Check the speed of the hand
    if (handsTrackFlag) drawHand(); // Draw the hand if it's been initialized
    break;

    case 1: // Volume Control Mode
    // Display the volume control
    volumeControl();
    break;

    case 2: // Channel Change Mode
    channelChange(changeChannel);// draw the change channel simbol
    // Add one to the timer
    channelTime++;
    // If the timer gets to 10, reset the counter and go back to waiting mode (0)
    if (channelTime>10) {
      channelTime = 0;
      mode = 0;
    }
    break;
  }
}

// This will draw the channel simbol on screen and send the change channel signal to Arduino
void channelChange(int sign) {
  String channelChange;
  pushStyle();
  // If we are changing to the next channel
  if (sign==1) {
    stroke(255, 0, 0);
    fill(255, 0, 0);
    // Send the signal only if it's the first loop
    if (channelTime == 0)myPort.write(1);
    textAlign(LEFT);
    channelChange = "Next Channel";
  }
  // Else, we are changing to the previous channel
  else {
    stroke(0, 255, 0);
    fill(0, 255, 0);
    // Send the signal only if it's the first loop
    if (channelTime == 0)myPort.write(2);
    textAlign(RIGHT);
    channelChange = "Previous Channel";
  }
  
  // Draw an arrow on screen
  strokeWeight(10);
  pushMatrix();
  translate(width/2,height/2);
  line(0,0,sign*200,0);
  triangle(sign*200,20,sign*200,-20,sign*250,0);
  textFont(font,20);
  text(channelChange,0,40);
  popMatrix();
  popStyle();
}

// Check if the hand movement matches what we want
void checkSpeed() {
  // Checkl only if we have two positions, so we can calculate the speed
  if (handVecList.size()>1) {
    // Check the distance between the two last hand positions
    PVector vel = PVector.sub(handVecList.get(0), handVecList.get(1));
    // If the distance is greater than 50 on the x-axis
    if (vel.x>50) {
      mode = 2;
      changeChannel = 1;
    }
    // If the distance is lesser than -50 on the x-axis
    else if (vel.x<-50) {
      changeChannel = -1;
      mode = 2;
    }
  }
}

// This will display the colume control gizmo and send the signal to Arduino
void volumeControl() {

  String volumeText = "You Can Now Change the Volume";
  fill(150);
  ellipse(screenCenterVec.x, screenCenterVec.y, 2*rad, 2*rad);
  fill(255);
  if (rot>prevRot) {
    fill(0, 0, 255);
    volumeText = "Volume Level Up";
    myPort.write(3);
  }
  else {
    fill(0, 255, 0);
    volumeText = "Volume Level Down";
    myPort.write(4);
  }
  prevRot = rot;
  text(volumeText, screenCenterVec.x, screenCenterVec.y);
  line(screenCenterVec.x, screenCenterVec.y, screenCenterVec.x+rad*cos(angle), screenCenterVec.y+rad*sin(angle));
}

// Draw the hand on screen
void drawHand() {

  stroke(255, 0, 0);

  pushStyle();
  strokeWeight(6);
  kinect.convertRealWorldToProjective(handVec, screenHandVec);
  point(screenHandVec.x, screenHandVec.y);
  popStyle();

  noFill();
  Iterator itr = handVecList.iterator(); 
  beginShape();
  while ( itr.hasNext ()) 
  { 
    PVector p = (PVector) itr.next(); 
    PVector sp = new PVector();
    kinect.convertRealWorldToProjective(p, sp);
    vertex(sp.x, sp.y);
  }
  endShape();
}


