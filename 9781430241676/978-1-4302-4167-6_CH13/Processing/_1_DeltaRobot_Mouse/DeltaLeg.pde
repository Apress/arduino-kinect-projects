class DeltaLeg {

  int id; // id of the leg
  PVector posVec = new PVector(); // Effector Position
  float servoAngle; // Anlgle between the servo and the XZ plane
  float legAngle; // Y rotation angle of the leg

  // Universal position of the joints
  PVector hipVec, kneeVec, ankleVec;

  float thigh, shin, baseSize, effectorSize; // Sizes of the robot's elements

  DeltaLeg(int id, float legAngle, float thigh, float shin, float base, float effector) {
    this.id = id;
    this.legAngle = legAngle;
    this.baseSize = base;
    this.effectorSize = effector;
    this.thigh = thigh;
    this.shin = shin;
  }

  void moveTo(PVector thisPos) {

    posVec.set(thisPos);
    PVector posTemp = vecRotY(thisPos, -legAngle);

    // find projection of a on the z=0 plane, squared
    float a2 = shin * shin - posTemp.z * posTemp.z;

    // calculate c with respect to base offset
    float c = dist(posTemp.x + effectorSize, posTemp.y, baseSize, 0);
    float alpha = (float) Math.acos((-a2 + thigh * thigh + c * c) / (2 * thigh * c)); 
    float beta = -(float) Math.atan2(posTemp.y, posTemp.x);

    servoAngle = alpha - beta;
    getWorldCoordinates();
  }

  void getWorldCoordinates () {
    // Unrotated Vectors of articulations
    hipVec = vecRotY(new PVector(baseSize, 0, 0), legAngle);
    kneeVec = vecRotZ(new PVector(thigh, 0, 0), servoAngle);
    kneeVec = vecRotY(kneeVec, legAngle);
    ankleVec = new PVector(posVec.x + (effectorSize * (float) Math.cos(legAngle)), posVec.y, 
    posVec.z - 5 + (effectorSize * (float) Math.sin(legAngle)));
  }

  PVector vecRotY(PVector vecIn, float phi) {
    // Rotates a vector around the universal y-axis
    PVector rotatedVec = new PVector();
    rotatedVec.x = vecIn.x * cos(phi) - vecIn.z * sin(phi);
    rotatedVec.z = vecIn.x * sin(phi) + vecIn.z * cos(phi);
    rotatedVec.y = vecIn.y;
    return rotatedVec;
  }

  PVector vecRotZ(PVector vecIn, float phi) {
    // Rotates a vector around the universal z-axis
    PVector rotatedVec = new PVector();
    rotatedVec.x = vecIn.x * cos(phi) - vecIn.y * sin(phi);
    rotatedVec.y = vecIn.x * sin(phi) + vecIn.y * cos(phi);
    rotatedVec.z = vecIn.z;
    return rotatedVec;
  }
  public void draw() {

    // Draw three lines to indicate the plane of each leg
    pushMatrix();
    translate(0, 0, 0);
    rotateY(-legAngle);
    translate(baseSize, 0, 0);
    if (id == 0) stroke(255, 0, 0);
    if (id == 1) stroke(0, 255, 0);
    if (id == 2) stroke(0, 0, 255);
    line(-baseSize / 2, 0, 0, 3 / 2 * baseSize, 0, 0);
    popMatrix();

    // Draw the Ankle Element
    stroke(150);
    strokeWeight(2);
    line(kneeVec.x, kneeVec.y, kneeVec.z, ankleVec.x, ankleVec.y, 
    ankleVec.z);
    stroke(150, 140, 140);
    fill(50);
    beginShape();
    vertex(hipVec.x, hipVec.y + 5, hipVec.z);
    vertex(hipVec.x, hipVec.y - 5, hipVec.z);
    vertex(kneeVec.x, kneeVec.y - 5, kneeVec.z);
    vertex(kneeVec.x, kneeVec.y + 5, kneeVec.z);
    endShape(PConstants.CLOSE);
    strokeWeight(1);

    // Draw the Hip Element
    stroke(0);
    fill(255);

    // Align the z axis to the direction of the bar
    PVector dirVec = PVector.sub(kneeVec, hipVec);
    PVector centVec = PVector.add(hipVec, PVector.mult(dirVec, 0.5f));
    PVector new_dir = dirVec.get();
    PVector new_up = new PVector(0.0f, 0.0f, 1.0f);
    new_up.normalize();
    PVector crss = dirVec.cross(new_up);
    float theAngle = PVector.angleBetween(new_dir, new_up);
    crss.normalize();

    pushMatrix();
    translate(centVec.x, centVec.y, centVec.z);
    rotate(-theAngle, crss.x, crss.y, crss.z);
    // rotate(servoAngle);
    box(dirVec.mag() / 50, dirVec.mag() / 50, dirVec.mag());
    popMatrix();
  }
}

