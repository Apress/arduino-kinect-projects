import processing.opengl.*;
import processing.serial.*;
import SimpleOpenNI.*;
import kinectOrbit.KinectOrbit;

// Initialize Orbit and simple-openni Objects
KinectOrbit myOrbit;
SimpleOpenNI kinect;
Serial myPort;
boolean serial = true;

// NITE
XnVSessionManager sessionManager;
XnVPointControl pointControl;

// Font for text on screen
PFont font;

// Variables for Hand Detection
boolean handsTrackFlag;
PVector handOrigin = new PVector();
PVector handVec = new PVector();
ArrayList<PVector> handVecList = new ArrayList<PVector>();
int handVecListSize = 30;
PVector[] realWorldPoint;
// Delta Robot
DeltaRobot dRobot;
PVector motionVec;
float gripRot;
float gripWidth;

private float[] serialMsg =  new float[5]; // Serial Values sent to Arduino
public void setup() {

  size(800, 600, OPENGL);
  smooth();

  // Orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.drawCS(true);
  myOrbit.drawGizmo(true);
  myOrbit.setCSScale(100);

  // Simple-openni object
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  // enable depthMap generation, hands + gestures
  kinect.enableDepth();
  kinect.enableGesture();
  kinect.enableHands();

  // setup NITE
  sessionManager = kinect.createSessionManager("Wave", "Wave");

  // Setup NITE.s Hand Point Control
  pointControl = new XnVPointControl();
  pointControl.RegisterPointCreate(this);
  pointControl.RegisterPointDestroy(this);
  pointControl.RegisterPointUpdate(this);

  sessionManager.AddListener(pointControl);

  // Array to store the scanned points
  realWorldPoint = new PVector[kinect.depthHeight() * kinect.depthWidth()];
  for (int i = 0; i < realWorldPoint.length; i++) {
    realWorldPoint[i] = new PVector();
  }
  // Initialize Font
  font = loadFont("SansSerif-12.vlw");

  // Initialize the Delta Robot to the real dimensions
  dRobot = new DeltaRobot(250, 430, 90, 80);

  if (serial) {
    // Initialize Serial Communication
    String portName = Serial.list()[0]; // This gets the first port on your computer.
    myPort = new Serial(this, portName, 9600);
  }
}

public void onPointCreate(XnVHandPointContext pContext) {
  println("onPointCreate:");
  handsTrackFlag = true;
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition()
    .getY(), pContext.getPtPosition().getZ());
  handVecList.clear();
  handVecList.add(handVec.get());
  handOrigin = handVec.get();
}

public void onPointDestroy(int nID) {
  println("PointDestroy: " + nID);
  handsTrackFlag = false;
}

public void onPointUpdate(XnVHandPointContext pContext) {
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition()
    .getY(), pContext.getPtPosition().getZ());
  handVecList.add(0, handVec.get());
  if (handVecList.size() >= handVecListSize) { // remove the last point
    handVecList.remove(handVecList.size() - 1);
  }
}

public void draw() {
  background(0);
  // Update Kinect data
  kinect.update();
  // update NITE
  kinect.update(sessionManager);
  myOrbit.pushOrbit(this); // Start Orbiting

  if (handsTrackFlag) {
    updateHand();
    drawHand();
  }
  // Draw the origin point, and the line to the current position
  pushStyle();
  stroke(0, 0, 255);
  strokeWeight(5);
  point(handOrigin.x, handOrigin.y, handOrigin.z);
  popStyle();
  stroke(0, 255, 0);
  line(handOrigin.x, handOrigin.y, handOrigin.z, handVec.x, handVec.y, 
  handVec.z);
  motionVec = PVector.sub(handVec, handOrigin);// Set the relative motion vector
  dRobot.moveTo(motionVec); // Move the robot to the relative motion vector
  dRobot.draw();  // Draw the delta robot in the current view.

  kinect.drawCamFrustum(); // Draw the Kinect cam

    myOrbit.popOrbit(this); // Stop Orbiting

  if (serial) { 
    sendSerialData();
  } 
  displayText();  // Print the data on screen
}


void updateHand() {
  // draw the 3d point depth map
  int steps = 3; // to speed up the drawing, draw every third point
  int index;
  pushStyle();
  stroke(255);
  // Initialize all the PVectors to the barycenter of the hand
  PVector handLeft = handVec.get();
  PVector handRight = handVec.get();
  PVector handTop = handVec.get();
  PVector handBottom = handVec.get();

  for (int y = 0; y < kinect.depthHeight(); y += steps) {
    for (int x = 0; x < kinect.depthWidth(); x += steps) {
      index = x + y * kinect.depthWidth();
      realWorldPoint[index] = kinect.depthMapRealWorld()[index].get();

      if (realWorldPoint[index].dist(handVec) < 100) {
        // Draw poin cloud defining the hand
        point(realWorldPoint[index].x, realWorldPoint[index].y, realWorldPoint[index].z);

        if (realWorldPoint[index].x > handRight.x) handRight = realWorldPoint[index].get();
        if (realWorldPoint[index].x < handLeft.x) handLeft = realWorldPoint[index].get();
        if (realWorldPoint[index].y > handTop.y) handTop = realWorldPoint[index].get();
        if (realWorldPoint[index].y < handBottom.y) handBottom = realWorldPoint[index].get();
      }
    }
  }
  // Draw Control Cube
  fill(100, 100, 200);
  pushMatrix();
  translate(handVec.x, handVec.y, handVec.z);
  rotateX(radians(handTop.y - handBottom.y));
  box((handRight.x - handLeft.x) / 2, (handRight.x - handLeft.x) / 2, 
  10);
  popMatrix();
  // Set the robot parameters
  gripWidth = lerp(gripWidth, map(handRight.x - handLeft.x, 65, 200, 0, 255), 0.2f);
  gripRot = lerp(gripRot, map(handTop.y - handBottom.y, 65, 200, 0, 255), 0.2f);
  dRobot.updateGrip(gripRot, gripWidth);
}
void drawHand() {

  stroke(255, 0, 0);
  pushStyle();
  strokeWeight(6);
  point(handVec.x, handVec.y, handVec.z);
  popStyle();

  noFill();
  Iterator itr = handVecList.iterator();
  beginShape();
  while (itr.hasNext ()) {
    PVector p = (PVector) itr.next();
    vertex(p.x, p.y, p.z);
  }
  endShape();
}
void sendSerialData() {

  myPort.write('X');

  for (int i=0;i<dRobot.numLegs;i++) {
    int serialAngle = (int)map(dRobot.servoAngles[i], radians(-90), radians(90), 0, 2000);
    
    serialMsg[i] = serialAngle;
    
    byte MSB = (byte)((serialAngle >> 8) & 0xFF);
    byte LSB = (byte)(serialAngle & 0xFF);
    
    myPort.write(MSB);
    myPort.write(LSB);
  }
  
  myPort.write((int)(gripRot));
  serialMsg[3] = (int)(gripRot);
  myPort.write((int)(gripWidth));
  serialMsg[4] = (int)(gripWidth);
}
void displayText() {

  // Display the current robot values and the messages being send to serial
  fill(255);
  textFont(font, 12);
  text("Position X: " + dRobot.posVec.x + "\nPosition Y: " + dRobot.posVec.y
    + "\nPosition Z: " + dRobot.posVec.z, 10, 20);
  text("Servo1: " + serialMsg[0] + "\nServo2: " + serialMsg[1] 
    + "\nServo3: " + serialMsg[2] + "\nGripRot: " + serialMsg[3] 
    + "\nGripWidth: " + serialMsg[4], 10, 80);
}



