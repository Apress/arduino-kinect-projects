import processing.serial.*;
import SimpleOpenNI.*;
import java.awt.*;
import java.awt.event.*;

SimpleOpenNI kinect;
Serial myPort;
PFont font;
PFont largeFont;
LCD lcd;

// User Input and Files
File[] files; // Existing user files
File userFile; // Current user
TextField name;
TextField birthdate;
Button b = new Button("New User");

// Serial Variables
boolean serial = true;
char[][] stringData = new char[4][13];
int currentLine;
boolean scan = true;

// User Data
float[] userData = new float[11];
int user; // Current user ID
String userName = "new User";
String userBirthDate = "00/00/0000";
int userAge;
float userBMI;
float userHeightTemp;

// Charts
float[][] chart;
File chartFile;
String today;

public void setup() {
  size(1200, 480);
  smooth();

  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableScene();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  font = loadFont("SansSerif-12.vlw");
  largeFont = loadFont("SansSerif-14.vlw");
  textFont(largeFont);

  lcd = new LCD();

  if (serial) {
    String portName = Serial.list()[0]; // This gets the first port
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n'); // don't generate a serialEvent() unless you get a newline
  }

  // Setting Up the User Input Elements
  name = new TextField(40);
  birthdate = new TextField(40);
  frame.add(name);
  frame.add(birthdate);
  frame.add(b);
  name.setBounds(20, height + 27, 200, 20);
  name.setText("Your Name");
  birthdate.setBounds(260, height + 27, 200, 20);
  birthdate.setText("Date of Birth dd/mm/yyyy");
  b.setBounds(520, height + 27, 100, 20);

  b.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent e) {
      userName = name.getText();
      userBirthDate = birthdate.getText();
      newUser(userName, userBirthDate);
    }
  }
  );

  // Acquire the user files already on the folder
  File directory = new File(dataPath(""));
  FilenameFilter filter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.startsWith("user_");
    }
  };

  files = directory.listFiles(filter);
  println("List of existing user files");
  for (File f : files) {
    println(f);
  }

  // Acquire the chart file
  chartFile = new File(dataPath("charts/Male_2-20_BMI.CSV"));
  readChart(chartFile);
  getDate();
}

public void draw() {
  kinect.update();
  background(0);
  lcd.setLcdArray(stringData);
  image(kinect.sceneImage(), 0, 0);

  if (kinect.getNumberOfUsers() != 0) {
    updateUserHeight();
  }

  if (kinect.isTrackingSkeleton(user)) {
    drawSkeleton(user);
    updateUserData(user);
  }

  if (lcd.foundWeight && scan) {
    userRecognition();
    userData[0] = lcd.data;
    userData[1] = userHeightTemp;

    userBMI = userData[0]/pow(userData[1] /1000, 2);
    saveUser();
    scan = false;
  }
  printUserData();
  drawChart();
}

public void getDate() {
  Calendar currentDate = Calendar.getInstance();
  SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
  today = formatter.format(currentDate.getTime());
  Date todayDate = currentDate.getTime();
  Date userDate = null;
  try {
    userDate = formatter.parse(userBirthDate);
  }
  catch (ParseException e) {
    e.printStackTrace();
  }
  long diff = todayDate.getTime() - userDate.getTime();
  userAge = (int) (diff/31556926000l);
}

public void newUser(String name, String birth) {
  // Start the user file
  if (name.equals("Your Name") || birth.equals("Date of Birth dd/mm/yyyy")) {
    println("Please insert your name and date of Birth");
  }
  else {
    DateFormat format = new SimpleDateFormat("dd/MM/yyyy");
    try {
      format.parse(birthdate.getText());
      PrintWriter output;
      userFile = new File(dataPath("user_" + userName + ".csv"));
      if (!userFile.exists()) {
        output = createWriter(userFile);
        output.println(name + "," + birth);
        output.flush(); // Write the remaining data
        output.close(); // Finish the file
        getDate();
        println("New User " + name + " created successfully");
      }
      else {
        setPreviousUser(userFile);
      }
    }
    catch (ParseException e) {
      System.out
        .println("Date " + birthdate.getText()
        + " is not valid according to "
        + ((SimpleDateFormat) format).toPattern()
        + " pattern.");
    }
  }
}

void updateUserData(int id) {
  // Left Arm Vectors
  PVector lHand = new PVector();
  PVector lElbow = new PVector();
  PVector lShoulder = new PVector();
  // Left Leg Vectors
  PVector lFoot = new PVector();
  PVector lKnee = new PVector();
  PVector lHip = new PVector();
  // Right Arm Vectors
  PVector rHand = new PVector();
  PVector rElbow = new PVector();
  PVector rShoulder = new PVector();
  // Right Leg Vectors
  PVector rFoot = new PVector();
  PVector rKnee = new PVector();
  PVector rHip = new PVector();

  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_HAND, lHand);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_ELBOW, lElbow);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_SHOULDER, lShoulder);
  // Left Leg
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_FOOT, lFoot);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_KNEE, lKnee);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_LEFT_HIP, lHip);
  // Right Arm
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_HAND, rHand);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_ELBOW, rElbow);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rShoulder);
  // Right Leg
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_FOOT, rFoot);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_KNEE, rKnee);
  kinect.getJointPositionSkeleton(id, SimpleOpenNI.SKEL_RIGHT_HIP, rHip);

  userData[2] = PVector.dist(rHand, rElbow); // Right Arm Length
  userData[3] = PVector.dist(rElbow, rShoulder); // Right Upper Arm Length
  userData[4] = PVector.dist(lHand, lElbow); // Left Arm Length
  userData[5] = PVector.dist(lElbow, lShoulder); // Left Upper Arm Length
  userData[6] = PVector.dist(lShoulder, rShoulder); // Shoulder Breadth
  userData[7] = PVector.dist(rFoot, rKnee); // Right Shin
  userData[8] = PVector.dist(rHip, rKnee); // Right Thigh
  userData[9] = PVector.dist(lFoot, lKnee); // Left Shin
  userData[10] = PVector.dist(lHip, lKnee); // Left Thigh
}

void updateUserHeight() {
  int steps = 3;
  int index;
  int[] userMap = kinect.getUsersPixels(SimpleOpenNI.USERS_ALL);
  PVector userCenter = new PVector();
  PVector[] realWorldPoint = new PVector[kinect.depthHeight() * kinect.depthWidth()];

  kinect.getCoM(1, userCenter); // Get the Center of Mass
  PVector userTop = userCenter.get();
  PVector userBottom = userCenter.get();

  for (int y = 0; y < kinect.depthHeight(); y += steps) {
    for (int x = 0; x < kinect.depthWidth(); x += steps) {
      index = x + y * kinect.depthWidth();
      realWorldPoint[index] = kinect.depthMapRealWorld()[index].get();
      if (userMap[index] != 0) {
        if (realWorldPoint[index].y > userTop.y)
          userTop = realWorldPoint[index].get();
        if (realWorldPoint[index].y < userBottom.y)
          userBottom = realWorldPoint[index].get();
      }
    }
  }

  userHeightTemp = lerp(userHeightTemp, userTop.y - userBottom.y, 0.2f);
}

private void saveUser() {
  userFile = new File(dataPath("user_" + userName + ".csv"));
  if (!userFile.exists()) {
    println("Please Enter your Name and Date of Birth");
  } 
  else {
    try {
      FileWriter writer = new FileWriter(userFile, true);
      BufferedWriter out = new BufferedWriter(writer);
      out.write(today);
      for (int i = 0; i < userData.length; i++) {
        out.write("," + userData[i]);
      }
      out.write("\n");
      out.flush(); // Write the remaining data
      out.close(); // Finish the file
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    println("user " + userName + " saved");
  }
}

float getUserDistance(float[] pattern) {
  float result = 0;
  for (int i = 0; i < pattern.length; i++) {
    result += pow(pattern[i] - userData[i + 2], 2);
  }
  return sqrt(result);
}

private void userRecognition() {
  float[] distances = new float[files.length];
  for (int i = 0; i < files.length; i++) {
    String line;
    try {
      BufferedReader reader = createReader(files[i]);
      while ( (line = reader.readLine ()) != null) {
        String[] myData = line.split(",");
        if (myData.length > 2) {
          float[] pattern = new float[9];
          for (int j = 3; j < myData.length; j++) {
            pattern[j - 3] = Float.valueOf(myData[j]);
          }
          distances[i] = getUserDistance(pattern);
        }
      }
    }
    catch (IOException e) {
      e.printStackTrace();
      println("error");
    }
  }

  int index = 0;
  float minDist = 1000000000;
  for (int j = 0; j < distances.length; j++) {
    if (distances[j] < minDist) {
      index = j;
      minDist = distances[j];
    }
  }
  if (minDist < 100)
    setPreviousUser(files[index]);
  println("Recognising User");
}

private void setPreviousUser(File file) {
  String line;
  try {
    BufferedReader reader = createReader(file);
    line = reader.readLine();
    String[] myData = line.split(",");
    userName = myData[0];
    userBirthDate = myData[1];
    getDate();
  }
  catch (IOException e) {
    e.printStackTrace();
    println("error");
  }
  println("User set to " + "userName, born on" + userBirthDate);
}

private void readChart(File file) {
  String line;
  int lineNumber = 0;
  try {
    int lines = count(file);
    chart = new float[lines][11];
    BufferedReader reader = createReader(file);

    while ( (line = reader.readLine ()) != null) {
      String[] myData = line.split(",");
      if (lineNumber == 0) {
      }
      else {
        for (int i = 0; i < myData.length; i++) {
          chart[lineNumber - 1][i] = Float.valueOf(myData[i]);
        }
      }
      lineNumber++;
    }
  }
  catch (IOException e) {
    e.printStackTrace();
    println("error");
  }
}

public int count(File file) {
  BufferedReader reader = createReader(file);
  String line;
  int count = 0;
  try {
    while ( (line = reader.readLine ()) != null) {
      count++;
    }
  }
  catch (IOException e) {
    e.printStackTrace();
    println("error");
  }
  return count;
}

private void drawChart() {
  float scaleX = 2;
  float scaleY = 10;
  pushStyle();
  stroke(255);
  noFill();
  pushMatrix();
  translate(0, height);
  scale(1, -1);
  translate(660, 20);
  line(0, 0, 500, 0);
  line(0, 0, 0, 300);
  for (int i = 1; i < chart[0].length; i++) {
    beginShape();

    for (int j = 0; j < chart.length - 1; j++) {
      vertex(chart[j][0] * scaleX, chart[j][i] * scaleY);
    }
    endShape();
  }
  strokeWeight(10);
  stroke(255, 0, 0);
  point(userAge*12*scaleX, userBMI*scaleY);
  popMatrix();
  popStyle();
}

private void printUserData() {
  fill(255);
  text("Data at " + today, 660, 20);
  text("Current User: " + userName, 660, 40);
  text("Date of Birth " + userBirthDate, 660, 60);
  text("Current Age " + userAge, 660, 80);
  text("User Weight: " + userData[0] + " " + lcd.units, 660, 100);
  text("User Height: " + userHeightTemp/1000 + " m", 660, 120);
  text("User BMI: " + userBMI + " kg/m2", 660, 140);
  fill(255, 255, 150);
  text("BMI at ages 2-20", 1000, 20);
}

void drawSkeleton(int userId) {
  pushStyle();
  stroke(255, 0, 0);
  strokeWeight(3);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  popStyle();
}

public void serialEvent(Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readString();
  inString = inString.substring(0, inString.indexOf('\n') - 1);
  if (inString != null) {
    if (inString.equals("S")) {
      currentLine = 0;
    }
    else if (inString.charAt(0) == 'X') {
      String newState = inString.substring(1);
      lcd.setState(Integer.valueOf(newState));
    }
    else {
      if (inString.length() == 13 && currentLine < 4) {
        for (int i = 0; i < stringData[0].length; i++) {
          stringData[currentLine][i] = inString.charAt(i);
        }
        currentLine++;
      }
    }
  }
  else {
    println("No data to display");
  }
}

// OpenNI Callbacks

public void onNewUser(int userId) {
  println("onNewUser - userId: " + userId);
  println(" start pose detection");
  kinect.startPoseDetection("Psi", userId);
  frame.setSize(width, height + 54);
}

public void onLostUser(int userId) {
  println("onLostUser - userId: " + userId);
}

public void onStartCalibration(int userId) {
  println("onStartCalibration - userId: " + userId);
}

public void onEndCalibration(int userId, boolean successfull) {
  println("onEndCalibration - userId: " + userId + ", successfull: "
    + successfull);
  if (successfull) {
    println(" User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
    user = userId;
  }
  else {
    println(" Failed to calibrate user !!!");
    println(" Start pose detection");
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

