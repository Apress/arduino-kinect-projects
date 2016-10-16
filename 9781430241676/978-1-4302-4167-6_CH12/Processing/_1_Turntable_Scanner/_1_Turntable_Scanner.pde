import processing.serial.*;
import processing.opengl.*;
import SimpleOpenNI.*;
import kinectOrbit.*;

// Initialize Orbit and simple-openni Objects
KinectOrbit myOrbit;
SimpleOpenNI kinect;

// Serial Parameters
Serial myPort; // Initialize the Serial Object
boolean serial = true; // Define if you're using serial communication
String turnTableAngle = "0"; // Variable for string coming from Arduino

// Initialize the ArrayLists for the pointClouds and the colors associated
ArrayList<PVector> scanPoints = new ArrayList<PVector>(); // PointCloud
ArrayList<PVector> scanColors = new ArrayList<PVector>(); // Object Colors
ArrayList<PVector> objectPoints = new ArrayList<PVector>(); // PointCloud
ArrayList<PVector> objectColors = new ArrayList<PVector>(); // Object Colors

// Scanning Space Variables
float baseHeight = -67; // Height of the Model's base
float modelWidth = 400;
float modelHeight = 400;
PVector axis = new PVector(0, baseHeight, 1050);

// Scan Parameters
int scanLines = 200;
int scanRes = 1;
boolean scanning;
boolean arrived;
float[] shotNumber = new float[3];
int currentShot = 0;

public void setup() {
  size(800, 600, OPENGL);
  
  // Orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.drawCS(true);
  myOrbit.drawGizmo(true);
  myOrbit.setCSScale(200);
  myOrbit.drawGround(true);
  
  // Simple-openni
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.alternativeViewPointDepthToImage();
  
  // Serial Communication
  if (serial) {
    String portName = Serial.list()[0]; // Get the first port
    myPort = new Serial(this, portName, 9600);
    
    // don't generate a serialEvent() unless you get a newline
    // character:
    myPort.bufferUntil('\n');
  }
  
  for (int i = 0; i < shotNumber.length; i++) {
    shotNumber[i] = i * (2 * PI) / shotNumber.length;
  }
  if (serial) { 
    moveTable(0);
  }
}

public void draw() {
  kinect.update(); // Update Kinect data
  background(0);
  
  myOrbit.pushOrbit(this); // Start Orbiting

  drawPointCloud(5);

  updateObject(scanLines, scanRes);

  if (arrived && scanning) { 
    scan();
  }

  drawObjects();
  drawBoundingBox(); // Draw Box Around Scanned Objects

  kinect.drawCamFrustum(); // Draw the Kinect cam

    myOrbit.popOrbit(this); // Stop Orbiting
}

void drawPointCloud(int steps) {
  
  // draw the 3D point depth map
  int index;
  PVector realWorldPoint;

  stroke(255);
  for (int y = 0; y < kinect.depthHeight(); y += steps) {
    for (int x = 0; x < kinect.depthWidth(); x += steps) {
      index = x + y * kinect.depthWidth();
      realWorldPoint = kinect.depthMapRealWorld()[index];
      stroke(150);
      point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
    }
  }
}

void drawObjects() {
  
  pushStyle();
  strokeWeight(4);
  
  for (int i = 1; i < objectPoints.size(); i++) {
    stroke(objectColors.get(i).x, objectColors.get(i).y, objectColors.get(i).z);

    point(objectPoints.get(i).x, objectPoints.get(i).y, objectPoints.get(i).z + axis.z);
  }
  
  for (int i = 1; i < scanPoints.size(); i++) {
    stroke(scanColors.get(i).x, scanColors.get(i).y, scanColors.get(i).z);
    point(scanPoints.get(i).x, scanPoints.get(i).y, scanPoints.get(i).z + axis.z);
  }
  
  popStyle();
}

void drawBoundingBox() {
  
  stroke(255, 0, 0);
  line(axis.x, axis.y, axis.z, axis.x, axis.y + 100, axis.z);
  noFill();
  pushMatrix();
  translate(axis.x, axis.x + baseHeight + modelHeight / 2, axis.z);
  box(modelWidth, modelHeight, modelWidth);
  popMatrix();
  
}

void scan() {
  
  for (PVector v : scanPoints) {
    boolean newPoint = true;
    for (PVector w : objectPoints) {
      if (v.dist(w) < 1)
        newPoint = false;
    }
    if (newPoint) {
      objectPoints.add(v.get());
      int index = scanPoints.indexOf(v);
      objectColors.add(scanColors.get(index).get());
    }
  }

  if (currentShot < shotNumber.length-1) {
    currentShot++;
    moveTable(shotNumber[currentShot]);
    println("new angle = " + shotNumber[currentShot]);
    println(currentShot);
    println(shotNumber);
  }
  else {
    scanning = false;
  }
  arrived = false;
}

void updateObject(int scanWidth, int step) {
  
  int index;
  PVector realWorldPoint;
  
  scanPoints.clear();
  scanColors.clear();

  float angle = map(Integer.valueOf(turnTableAngle), 100, 824, 2 * PI, 0);

  pushMatrix();
  translate(axis.x, axis.y, axis.z);
  rotateY(angle);
  line(0, 0, 100, 0);
  popMatrix();

  int xMin = (int) (kinect.depthWidth() / 2 - scanWidth / 2); 
  int xMax = (int) (kinect.depthWidth() / 2 + scanWidth / 2);
  
  for (int y = 0; y < kinect.depthHeight(); y += step) {
    for (int x = xMin; x < xMax; x += step) {
      
      index = x + (y * kinect.depthWidth());
      realWorldPoint = kinect.depthMapRealWorld()[index];
      color pointCol = kinect.rgbImage().pixels[index];

      if (realWorldPoint.y < modelHeight + baseHeight && realWorldPoint.y > baseHeight) { // Check y
        if (abs(realWorldPoint.x - axis.x) < modelWidth / 2) { // Check x
          if (realWorldPoint.z < axis.z + modelWidth / 2 && realWorldPoint.z > axis.z -
            modelWidth / 2) { // Check z
            PVector rotatedPoint;

            realWorldPoint.z -= axis.z;
            realWorldPoint.x -= axis.x;
            rotatedPoint = vecRotY(realWorldPoint, angle);

            scanPoints.add(rotatedPoint.get());
            scanColors.add(new PVector(red(pointCol), green(pointCol), blue(pointCol)));
          }
        }
      }
    }
  }
}

PVector vecRotY(PVector vecIn, float phi) {
  // Rotate the vector around the y-axis
  PVector rotatedVec = new PVector();
  rotatedVec.x = vecIn.x * cos(phi) - vecIn.z * sin(phi);
  rotatedVec.z = vecIn.x * sin(phi) + vecIn.z * cos(phi);
  rotatedVec.y = vecIn.y;
  return rotatedVec;
}

void moveTable(float angle) {
  myPort.write('S');
  myPort.write((int) map(angle, 0, 2*PI, 0, 255));
  println("new angle = " + angle);
}

public void serialEvent(Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    if (inString.equals("end")) {
      println("end");
    }

    else if (inString.equals("start")) {
      println("start");
    }
    else if (inString.equals("arrived")) {
      arrived = true;
      println("arrived");
    }
    else {
      turnTableAngle = inString;
    }
  }
}

public void keyPressed() {
  switch (key) {
  case 'r': // Send the turntable to start position
    moveTable(0);
    scanning = false;
    break;
  case 's': // Start scanning
    objectPoints.clear();
    objectColors.clear();
    currentShot = 0;
    scanning = true;
    arrived = false;
    moveTable(0);
    break;
  case 'c': // Clear the object points
    objectPoints.clear();
    objectColors.clear();
    break;
  case 'e': // Export the object points
    exportPly('0');
    break;
  case 'm': // Move the turntable to the x mouse position
    moveTable(map(mouseX, 0, width, 0, 360));
    scanning = false;
    break;
  case '+': // Increment the number of scanned lines
    scanLines++;
    println(scanLines);
    break;
  case '-': // Decrease the number of scanned lines
    scanLines--;
    println(scanLines);
    break;
  }
}

void exportPly(char key) {
PrintWriter output;
String viewPointFileName;
viewPointFileName = "myPoints" + key + ".ply";
output = createWriter(dataPath(viewPointFileName));

output.println("ply");
output.println("format ascii 1.0");
output.println("comment This is your Processing ply file");
output.println("element vertex " + (objectPoints.size()-1));
output.println("property float x");
output.println("property float y");
output.println("property float z");
output.println("property uchar red");
output.println("property uchar green");
output.println("property uchar blue");
output.println("end_header");

for (int i = 0; i < objectPoints.size() - 1; i++) {
output.println((objectPoints.get(i).x / 1000) + " "
+ (objectPoints.get(i).y / 1000) + " "
+ (objectPoints.get(i).z / 1000) + " "
+ (int) objectColors.get(i).x + " "
+ (int) objectColors.get(i).y + " "
+ (int) objectColors.get(i).z);
}

output.flush(); // Write the remaining data
output.close(); // Finish the file
}
