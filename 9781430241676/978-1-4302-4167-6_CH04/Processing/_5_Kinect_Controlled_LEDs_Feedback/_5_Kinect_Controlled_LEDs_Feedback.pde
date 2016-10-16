import SimpleOpenNI.*;
import processing.serial.*;

SimpleOpenNI kinect;
Serial myPort;

PVector handVec = new PVector();
PVector mapHandVec = new PVector();
color handPointCol = color(255, 0, 0);

int photoVal;

void setup() {

  kinect = new SimpleOpenNI(this);

  // disable mirror
  kinect.setMirror(true);

  // enable depthMap generation, hands and gestures
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableGesture();
  kinect.enableHands();

  // add focus gesture to initialise tracking
  kinect.addGesture("Wave");

  size(kinect.depthWidth(), kinect.depthHeight());

  String portName = Serial.list()[0]; // This gets the first port on your computer.
  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
}

void draw() {

  kinect.update();

  kinect.convertRealWorldToProjective(handVec,mapHandVec);
  
  // Draw RGB or depthImageMap according to Photocell 
  if (photoVal<500) {
    image(kinect.rgbImage(), 0, 0);
  } else {
    image(kinect.depthImage(), 0, 0);
  }

  strokeWeight(10);
  stroke(handPointCol);
  point(mapHandVec.x, mapHandVec.y);

  // Send a marker to indicate the beginning of the communication
  myPort.write('S');
  // Send the value of the mouse's x-position
  myPort.write(int(255*mapHandVec.x/width));
  // Send the value of the mouse's y-position
  myPort.write(int(255*mapHandVec.y/height));
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {

    println("String value = " + inString);
    // trim off any whitespace:
    inString = trim(inString);
    println("Trimmed String value = " + inString);
    // convert to an int and map to the screen height:
    photoVal = int(inString); 
    println("float value = " + photoVal);
  } 
  else {
    // increment the horizontal position:
    println("No data to display");
  }
}


void onCreateHands(int handId, PVector pos, float time)
{
  println("onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time);
  handVec = pos;
  handPointCol = color(0, 255, 0);
}

void onUpdateHands(int handId, PVector pos, float time)
{
  //println("onUpdateHandsCb - handId: " + handId + ", pos: " + pos + ", time:" + time);
  handVec = pos;
}
void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  println("onRecognizeGesture - strGesture: " + strGesture + ", idPosition: " + idPosition + ", endPosition:" + endPosition);

  kinect.removeGesture(strGesture); 
  kinect.startTrackingHands(endPosition);
}

