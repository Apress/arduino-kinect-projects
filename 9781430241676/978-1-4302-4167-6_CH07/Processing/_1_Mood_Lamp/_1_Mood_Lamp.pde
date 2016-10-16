import processing.opengl.*;
import kinectOrbit.KinectOrbit;
import processing.serial.Serial;
import SimpleOpenNI.SimpleOpenNI;

SimpleOpenNI kinect;
KinectOrbit myOrbit;
Serial myPort;

File lampsFile;

boolean serial = true;

int userID;
ArrayList<Lamp> lamps = new ArrayList<Lamp>();
PVector userCenter = new PVector();

public void setup() {

  size(800, 600, OPENGL);
  smooth();

  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  myOrbit = new KinectOrbit(this, 0);
  myOrbit.drawGizmo(true);

  lampsFile = new File(dataPath("lamps.txt"));
  
  if (serial) {
    String portName = Serial.list()[0]; // This gets the first port
    myPort = new Serial(this, portName, 9600);
  }
}

public void draw() {

  kinect.update();
  background(0);

  myOrbit.pushOrbit();

  drawPointCloud(6);

  // If we have recognized a user
  if (kinect.getNumberOfUsers() != 0) {
    kinect.getCoM(userID, userCenter); // Get the Center of Mass
    for (int i = 0; i < lamps.size(); i++) {
      lamps.get(i).updateUserPos(userCenter); // Update the lamps
    }
    if (kinect.isTrackingSkeleton(userID)) {
      userControl(userID); // User control behaviors
      drawSkeleton(userID); // draw the skeleton if it's available
    } 
    else {
      drawUserPoints(3); // Update and draw the User points
    }
  }

  for (int i = 0; i < lamps.size(); i++) {
    lamps.get(i).draw();
  }

  // draw the kinect cam
  kinect.drawCamFrustum();

  myOrbit.popOrbit();

  if (serial)
    sendSerialData();

  // if(frameCount%10==0)save("image" + frameCount + ".jpg");
}

void saveLamps() {
  String[] lines = new String[lamps.size()];
  for (int i = 0; i < lamps.size(); i++) {
    lines[i] = String.valueOf(lamps.get(i).pos.x) + " "
      + String.valueOf(lamps.get(i).pos.y) + " "
      + String.valueOf(lamps.get(i).pos.z) + " "
      + Integer.toString(lamps.get(i).getColor()[0]) + " "
      + Integer.toString(lamps.get(i).getColor()[1]) + " "
      + Integer.toString(lamps.get(i).getColor()[2]);
  }
  saveStrings(lampsFile, lines);
}

void loadLamps() {
  String lines[] = PApplet.loadStrings(lampsFile);
  for (int i = 0; i < lines.length; i++) {
    String[] coordinates = lines[i].split(" ");
    Lamp lampTemp = new Lamp(Float.valueOf(coordinates[0]), 
    Float.valueOf(coordinates[1]), 
    Float.valueOf(coordinates[2]));
    lampTemp.setColor(Integer.valueOf(coordinates[3]), 
    Integer.valueOf(coordinates[4]), 
    Integer.valueOf(coordinates[5]));
    lamps.add(lampTemp);
  }
}

private void userControl(int userId) {

  PVector head = new PVector();
  // Right Arm Vectors
  PVector rHand = new PVector();
  PVector rElbow = new PVector();
  PVector rShoulder = new PVector();
  // Left Arm Vectors
  PVector lHand = new PVector();

  // Head
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);
  // Right Arm
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, 
  rHand);
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, 
  rElbow);
  kinect.getJointPositionSkeleton(userId, 
  SimpleOpenNI.SKEL_RIGHT_SHOULDER, rShoulder);
  // Left Arm
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, 
  lHand);		

  PVector rForearm = PVector.sub(rShoulder, rElbow);
  PVector rArm = PVector.sub(rElbow, rHand);

  // Lamp Control
  if (PVector.angleBetween(rForearm, rArm) < PI / 8f) {
    for (int i = 0; i < lamps.size(); i++) {
      PVector handToLamp = PVector.sub(rHand, lamps.get(i).pos);
      if (PVector.angleBetween(rArm, handToLamp) < PI / 4) {
        PVector colors = PVector.sub(head, lHand);
        lamps.get(i).setColor((int) colors.x / 2, 
        (int) colors.y / 2, (int) colors.z / 2);
        lamps.get(i).drawSelected();
      }
    }
  }

  // Lamp Creation
  if (head.dist(rHand) < 200 && head.dist(lHand) < 200) {
    boolean tooClose = false;
    for (int i = 0; i < lamps.size(); i++) {
      if (userCenter.dist(lamps.get(i).pos) < 200)
        tooClose = true;
    }
    if (!tooClose) {
      Lamp lampTemp = new Lamp(userCenter.x, userCenter.y, 
      userCenter.z);
      lamps.add(lampTemp);
    }
  }
}

void sendSerialData() {
  // Serial Communcation
  for (int i = 0; i < lamps.size(); i++) {
    myPort.write('S');
    myPort.write(i);
    myPort.write(lamps.get(i).W);
    myPort.write(lamps.get(i).R);
    myPort.write(lamps.get(i).G);
    myPort.write(lamps.get(i).B);
  }
}

void drawPointCloud(int steps) {

  // draw the 3d point depth map
  int[] depthMap = kinect.depthMap();
  int index;
  PVector realWorldPoint;
  stroke(255);
  for (int y = 0; y < kinect.depthHeight(); y += steps) {
    for (int x = 0; x < kinect.depthWidth(); x += steps) {
      index = x + y * kinect.depthWidth();
      if (depthMap[index] > 0) {
        realWorldPoint = kinect.depthMapRealWorld()[index];
        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
      }
    }
  }
}

void drawUserPoints(int steps) {

  int[] userMap = kinect.getUsersPixels(SimpleOpenNI.USERS_ALL);

  // draw the 3d point depth map
  PVector[] realWorldPoint = new PVector[kinect.depthHeight()
    * kinect.depthWidth()];
  int index;
  pushStyle();
  stroke(255);
  for (int y = 0; y < kinect.depthHeight(); y += steps) {
    for (int x = 0; x < kinect.depthWidth(); x += steps) {
      index = x + y * kinect.depthWidth();
      // draw the projected point
      realWorldPoint[index] = kinect.depthMapRealWorld()[index].get();
      if (userMap[index] != 0) {
        strokeWeight(2);
        stroke(0, 255, 0);
        point(realWorldPoint[index].x, realWorldPoint[index].y, 
        realWorldPoint[index].z);
      }
    }
  }
  popStyle();
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId) {
  strokeWeight(3);

  // to get the 3d joint data
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, 
  SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, 
  SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, 
  SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, 
  SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, 
  SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, 
  SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, 
  SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, 
  SimpleOpenNI.SKEL_TORSO);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, 
  SimpleOpenNI.SKEL_LEFT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, 
  SimpleOpenNI.SKEL_LEFT_FOOT);

  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, 
  SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, 
  SimpleOpenNI.SKEL_RIGHT_FOOT);

  strokeWeight(1);
}

void drawLimb(int userId, int jointType1, int jointType2) {
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float confidence;

  // draw the joint position
  confidence = kinect.getJointPositionSkeleton(userId, jointType1, 
  jointPos1);
  confidence = kinect.getJointPositionSkeleton(userId, jointType2, 
  jointPos2);

  stroke(255, 0, 0, confidence * 200 + 55);
  line(jointPos1.x, jointPos1.y, jointPos1.z, jointPos2.x, jointPos2.y, 
  jointPos2.z);
}

public void keyPressed() {

  switch (key) {
  case 's':
    saveLamps();
    break;
  case 'l':
    loadLamps();
    break;
  }
}

public void onNewUser(int userId) {
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  kinect.startPoseDetection("Psi", userId);
  userID = userId;
}

public void onLostUser(int userId) {
  println("onLostUser - userId: " + userId);
}

public void onStartCalibration(int userId) {
  println("onStartCalibration - userId: " + userId);
}

public void onEndCalibration(int userId, boolean successfull) {
  println("onEndCalibration - userId: " + userId + ", successful: "
    + successfull);

  if (successfull) {
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } 
  else {
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    kinect.startPoseDetection("Psi", userId);
  }
}

public void onStartPose(String pose, int userId) {
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  kinect.stopPoseDetection(userId);
  kinect.requestCalibrationSkeleton(userId, true);
}

public void onEndPose(String pose, int userId) {
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

