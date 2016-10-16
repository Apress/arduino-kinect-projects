class DeltaRobot {

  PVector posVec = new PVector(); // Position of the Effector
  PVector zeroPos;
  int numLegs = 3; // Number of legs

  DeltaLeg[] leg = new DeltaLeg[numLegs]; // Create an array of deltaLegs
  float[] servoAngles = new float[numLegs]; // Store the angles of each leg
  float thigh, shin, baseSize, effectorSize; // Delta-Robot dimensions
  float gripRot = 100;
  float gripWidth = 100;
  // Maximum dimensions of the Robot space
  float robotSpanX = 500;
  float robotSpanZ = 500;
  float maxH;
  
DeltaRobot(float thigh, float shin, float baseSize, float effectorSize) {

    // Set the variables
    this.thigh = thigh;
    this.shin = shin;
    this.baseSize = baseSize;
    this.effectorSize = effectorSize;
    this.maxH = -(thigh + shin) * 0.9f; // Avoid the effector going out of range
    zeroPos = new PVector(0, maxH / 2, 0);
    
for (int i = 0; i < numLegs; i++) {
      float legAngle = (i * 2 * PI / numLegs) + PI / 6;
      leg[i] = new DeltaLeg(i, legAngle, thigh, shin,  baseSize, effectorSize);
    }
  }

public void moveTo(PVector newPos) {

    posVec.set(PVector.add(newPos, zeroPos));
    float xMax = robotSpanX * 0.5f;
    float xMin = -robotSpanX * 0.5f;
    float zMax = robotSpanZ * 0.5f;
    float zMin = -robotSpanZ * 0.5f;
    float yMax = -200;
    float yMin = 2*maxH+200;

    if (posVec.x > xMax) posVec.x = xMax;
    if (posVec.x < xMin) posVec.x = xMin;
    if (posVec.y > yMax) posVec.y = yMax;
    if (posVec.y < yMin) posVec.y = yMin;
    if (posVec.z > zMax) posVec.z = zMax;
    if (posVec.z < zMin) posVec.z = zMin;
    
    for (int i = 0; i < numLegs; i++) {
      leg[i].moveTo(posVec); // Move the legs to the new position
      servoAngles[i] = leg[i].servoAngle; // Get the servo angles
    }
  }
  
   public void draw() {

    stroke(50);
    pushMatrix();
    translate(0, -maxH, 0);

    for (int i = 0; i < numLegs; i++) {
      leg[i].draw();
    }
    
    drawEffector();
    //drawGrip();
    popMatrix();
  }
  
     void drawEffector() {
    
    // Draw the Effector Structure
    stroke(150);
    fill(150, 50);
      beginShape();
      for (int i = 0; i < numLegs; i++) {
        vertex(leg[i].ankleVec.x, leg[i].ankleVec.y, 
        leg[i].ankleVec.z);
      }
      endShape(CLOSE);

    // Draw Gripper
    stroke(200, 200, 255);
    fill(200, 50);

    // Translate our Coordinate System to the effector position
    pushMatrix();
    translate(posVec.x, posVec.y - 5, posVec.z);
    rotateX(-PI/2);	// Rotate The CS, so we can drwa 
    ellipse(0, 0, effectorSize / 1.2f, effectorSize / 1.2f);
    rotate(map(gripRot, 35, 180, -PI / 2, PI / 2));

    for (int j = -1; j < 2; j += 2) {
      translate(0, 2 * j, 0);
      beginShape();
      vertex(-30, 0, 0);
      vertex(30, 0, 0);
      vertex(30, 0, -35);
      vertex(15, 0, -50);
      vertex(-15, 0, -50);
      vertex(-30, 0, -35);
      endShape(CLOSE);

      for (int i = -1; i < 2; i += 2) {
        pushMatrix();
        translate(i * 20, 0, -30);
        rotateX(PI / 2);
        ellipse(0, 0, 10, 10);
        rotate(i * map(gripWidth, 50, 150, 0, PI / 2.2f));
        rect(-5, -60, 10, 60);
        translate(0, -50, 0);
        rotate(-i * map(gripWidth, 50, 150, 0, PI / 2.2f));
        rect(-5, -60, 10, 60);
        popMatrix();
      }
    }
    popMatrix();
  }
  public void updateGrip(float gripRot, float gripWidth) {
    this.gripRot = gripRot;
    this.gripWidth = gripWidth;
  }
}



