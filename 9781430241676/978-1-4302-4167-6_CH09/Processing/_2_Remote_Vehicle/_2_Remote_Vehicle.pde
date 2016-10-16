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
String Ctext;
String dir;


// Variables for Hand Detection
boolean handsTrackFlag = false;
boolean circleTrackFlag = false;
PVector screenHandVec = new PVector();
PVector handVec = new PVector();
int t=0;
float rad;
PVector centerVec = new PVector();
PVector screenCenterVec = new PVector();

PVector v = new PVector();
boolean automated=true;

boolean serial = false;

int Val01, Val02, Val03, Val04;
float temp01, temp02, temp03, temp04;

void setup() {

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
  // Add it to the session  

  sessionManager.AddListener(pointControl);
  sessionManager.AddListener(circleDetector);

  // Set the sketch size to match the depth map
  size(kinect.depthWidth(), kinect.depthHeight()); 
  smooth();

  // Initialize Font
  font = loadFont("SansSerif-12.vlw");
  Ctext="Automated mode ON";
  dir = "-";

  //Initialize Serial Communication
  if (serial) {
    String portName = Serial.list()[0]; // This gets the first port
    myPort = new Serial(this, portName, 9600);
  }
}

void draw()
{
  background(0);

  PVector centerL = new PVector(width/2, height/2);  

  // Update Kinect data
  kinect.update();
  // update NITE
  kinect.update(sessionManager);

  // draw depthImageMap
  image(kinect.depthImage(), 0, 0);

  //displacement between the centre and the hand in 2D
  v.x=screenHandVec.x-centerL.x;
  v.y=screenHandVec.y-centerL.y;


  if (handsTrackFlag) {
    drawHand();
    drawArrow(v, centerL);
    controlCar();
  }
  if (circleTrackFlag) {
    drawCircle();
  }
  textDisplay();
  if (serial) {
    sendSerialData();
  }
}
void controlCar() {
  temp01 = screenHandVec.x-width/2;
  temp02 = height/2- screenHandVec.y;


  temp03= int(map(temp01, -width/2, width/2, 0, 255));

  if (temp03<75) {
    Val01=1;
  }
  if (temp03>175) {
    Val01=2;
  }
  if (temp03>75 && temp03<175) {
    Val01=0;
  }

  temp04= int(map(temp02, -height/2, height/2, -255, 250));

  if (temp04>0 && temp04>50) {
    Val02=1;
  }
  else if (temp04<0 && temp04<-50) {
    Val02=2;
  }
  else {
    Val02=0;
  }  
  if (temp04>100 && temp04<150) {
    Val03=140;
  }
  if (temp04>150) {
    Val03=200;
  }

  if (temp04<-100 && temp04>-150) {
    Val03=140;
  }
  if (temp04<-150) {
    Val03=200;
  }


  //println(Val01 + "   "  + Val02+ "   "  + Val03+ "   "  +Val04 );
}
// Draw the hand on screen
void drawHand() {

  stroke(255, 0, 0);

  pushStyle();
  strokeWeight(6);
  kinect.convertRealWorldToProjective(handVec, screenHandVec);
  point(screenHandVec.x, screenHandVec.y);
  popStyle();
}
void drawCircle() {

  if (t==1)automated=!automated;
  if (automated==true) {
    Val04=0;
    noFill();
    strokeWeight(6);
    stroke(0, 255, 0);
    ellipse(screenCenterVec.x, screenCenterVec.y, 2*rad, 2*rad);
    textAlign(LEFT);
    Ctext = "Automated mode ON";
  }
  if (automated==false) {
    Val04=1;
    noFill();
    strokeWeight(6);
    stroke(255, 0, 0);
    ellipse(screenCenterVec.x, screenCenterVec.y, 2*rad, 2*rad);
    textAlign(LEFT);
    Ctext = "Automated mode OFF";
  }

  println(automated);
}

void drawArrow(PVector v, PVector loc) {

  pushMatrix();
  float arrowsize = 4;
  translate(loc.x, loc.y);
  stroke(255, 0, 0);
  strokeWeight(2);
  rotate(v.heading2D());
  float len = v.mag();
  line(0, 0, len, 0);
  line(len, 0, len-arrowsize, +arrowsize/2);
  line(len, 0, len-arrowsize, -arrowsize/2);
  popMatrix();
}
void textDisplay() {
  text(Ctext, 10, kinect.depthHeight()-10);
  int value;
  if (Val02==0)value=0;
  else value = Val03;
  text("Speed: "+value, 10, kinect.depthHeight()-30); 
  text("Direction: "+dir, 10, kinect.depthHeight()-50);

  if (Val02==1 && Val01==0) {
    dir ="N";
  }
  if (Val02==2 && Val01==0) {
    dir="S";
  }
  if (Val02==0 && Val01==1) {
    dir="W";
  }
  if (Val02==0 && Val01==2) {
    dir="E";
  }
  if (Val02==1 && Val01==2) {
    dir="NE";
  }
  if (Val02==2 && Val01==2) {
    dir="SE";
  }
  if (Val02==2 && Val01==1) {
    dir="SW";
  }
  if  (Val02==1 && Val01==1) {
    dir="NW";
  }
}
void sendSerialData() {
  // Serial Communcation
  myPort.write('S');
  myPort.write(Val01);
  myPort.write(Val02);
  myPort.write(Val03);
  myPort.write(Val04);
}

////////////////////////////////////////////////////////////////////////////////////////////

// XnVPointControl callbacks

void onPointCreate(XnVHandPointContext pContext)
{
  println("onPointCreate:");
  handsTrackFlag = true;
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
}

void onPointDestroy(int nID)
{
  println("PointDestroy: " + nID);
  handsTrackFlag = false;
}

void onPointUpdate(XnVHandPointContext pContext)
{
  handVec.set(pContext.getPtPosition().getX(), pContext.getPtPosition().getY(), pContext.getPtPosition().getZ());
}

// XnVCircleDetector callbacks

void onCircle(float fTimes, boolean bConfident, XnVCircle circle)
{
  println("onCircle: " + fTimes + " , bConfident=" + bConfident); 
  circleTrackFlag = true;
  t++;
  centerVec.set(circle.getPtCenter().getX(), circle.getPtCenter().getY(), handVec.z);
  kinect.convertRealWorldToProjective(centerVec, screenCenterVec);
  rad = circle.getFRadius();
}

void onNoCircle(float fTimes, int reason)
{
  println("onNoCircle: " + fTimes + " , reason= " + reason);  
  circleTrackFlag = false;
  t=0;
}

