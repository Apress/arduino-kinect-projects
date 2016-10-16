import processing.opengl.*;
import SimpleOpenNI.*;
import processing.serial.*;
import kinectOrbit.*;
import processing.dxf.*;

// Initialize Orbit and simple-openni Objects
KinectOrbit myOrbit;
SimpleOpenNI kinect;

XnVSessionManager sessionManager;
XnVPointControl pointControl;

boolean record = false;

// Serial Parameters
Serial myPort; // Initialize the Serial Object
boolean serial = true; // Define if we're using serial communication

private GloveInterface glove;
int thresholdDist = 50;
ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> selPoints = new ArrayList<Point>();
ArrayList<Line> lines = new ArrayList<Line>();
ArrayList<Shape> shapes = new ArrayList<Shape>();

public void setup() {

  size(800, 600, OPENGL);

  // Orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.drawGizmo(true);
  myOrbit.drawCS(true);
  myOrbit.setCSScale(200);

  // Simple-openni
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);
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

  sessionManager.AddListener(pointControl);

  // Serial Communication
  if (serial) {
    String portName = Serial.list()[0]; // Get the first port
    myPort = new Serial(this, portName, 9600);
    // don't generate a serialEvent() unless you get a newline
    // character:
    myPort.bufferUntil('\n');
  }

  glove = new GloveInterface();
}

public void draw() {

  kinect.update(); // Update Kinect data
  kinect.update(sessionManager); // update NITE
  background(0);

  switch (glove.currentFinger) {
  case 0:
    movePoint();
    break;
  case 1:
    addPoint();
    break;
  case 2:
    addLine();
    break;
  case 3:
    addShape();
    break;
  }

  myOrbit.pushOrbit(this); // Start Orbiting

  if (record == true) {
    beginRaw(DXF, "output.dxf"); // Start recording to the file
  }

  glove.draw();

  drawClosestPoint();

  for (Point pt : points) {
    pt.draw();
  }
  for (Line ln : lines) {
    ln.draw();
  }
  for (Shape srf : shapes) {
    srf.draw();
  }

  if (record == true) {
    endRaw();
    record = false; // Stop recording to the file
  }

  myOrbit.popOrbit(this); // Stop Orbiting

  glove.drawData();
}

private void movePoint() {
  for (Point pt : points) {
    if (glove.pos.dist(pt.pos) < thresholdDist) {
      pt.setPos(glove.pos);
    }
  }
}

private void addPoint() {

  Point tempPt = new Point(glove.pos.get());
  boolean tooClose = false;
  for (Point pt : points) {
    if (tempPt.pos.dist(pt.pos) < thresholdDist) {
      tooClose = true;
    }
  }
  if (!tooClose) {
    points.add(tempPt);
  }
}

private void addLine() {

  for (Point pt : points) {
    if (glove.pos.dist(pt.pos) < thresholdDist) {
      pt.select();
      if (!selPoints.contains(pt)) {
        selPoints.add(pt);
      }
      if (selPoints.size() > 1) {
        Line lineTemp = new Line(selPoints.get(0), selPoints.get(1));
        lines.add(lineTemp);
        unSelectAll();
      }
    }
  }
}

private void addShape() {

  for (Point pt : points) {
    if (glove.pos.dist(pt.pos) < thresholdDist) {
      pt.select();
      if (!selPoints.contains(pt)) {
        selPoints.add(pt);
      }
      if (selPoints.size() > 2) {
        Shape surfTemp = new Shape(selPoints);
        shapes.add(surfTemp);
        unSelectAll();
      }
    }
  }
}

void unSelectAll() {
  for (Point pt : points) {
    pt.unSelect();
  }
  selPoints.clear();
}

void drawClosestPoint() {
  for (Point pt : points) {
    if (glove.pos.dist(pt.pos) < thresholdDist) {
      pushStyle();
      stroke(0, 150, 200);
      strokeWeight(15);
      point(pt.pos.x, pt.pos.y, pt.pos.z);
      popStyle();
    }
  }
}

public void serialEvent(Serial myPort) {
  String inString = myPort.readStringUntil('\n');
  if (inString != null) {
    String[] fingerStrings = inString.split(" ");
    if (fingerStrings.length == 4) {
      glove.setFingerValues(fingerStrings);
    }
  }
}

public void keyPressed() {
  switch (key) {
  case '1':
    glove.calibrateFinger(0, 0);
    break;
  case '2':
    glove.calibrateFinger(1, 0);
    break;
  case '3':
    glove.calibrateFinger(2, 0);
    break;
  case '4':
    glove.calibrateFinger(3, 0);
    break;
  case 'q':
    glove.calibrateFinger(0, 1);
    break;
  case 'w':
    glove.calibrateFinger(1, 1);
    break;
  case 'e':
    glove.calibrateFinger(2, 1);
    break;
  case 'r':
    glove.calibrateFinger(3, 1);
    break;
  case 'd':
    record = true;
    break;
  }
}

// XnVPointControl callbacks

public void onPointCreate(XnVHandPointContext pContext) {
  println("onPointCreate:");
  PVector handVec = new PVector(pContext.getPtPosition().getX(), pContext
    .getPtPosition().getY(), pContext.getPtPosition().getZ());
  glove.setZeroPos(handVec.get());
}

public void onPointDestroy(int nID) {
  println("PointDestroy: " + nID);
}

public void onPointUpdate(XnVHandPointContext pContext) {
  PVector handVec = new PVector(pContext.getPtPosition().getX(), pContext
    .getPtPosition().getY(), pContext.getPtPosition().getZ());
  glove.setPosition(handVec);
}

