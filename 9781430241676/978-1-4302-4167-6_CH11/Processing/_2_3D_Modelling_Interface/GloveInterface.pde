public class GloveInterface {

  File fingerCal;
  PVector pos = new PVector();
  private PVector zeroPos = new PVector();
  public PVector handPos = new PVector();
  float[] fingerState = new float[4];
  float[] fingerStateCal = new float[4];
  float[][] fingerCalibration = {{0,600},{0,600},{0,600},{0,600}};
  public int currentFinger = 99;

  GloveInterface() {
    fingerCal = new File("data/fingerCal.txt");
    if (fingerCal.exists()) {
      getCalibration();
    }
    
  }

  public void setFingerValues(String[] fingerStrings) {
    // Get the finger values

      for (int i = 0; i < fingerState.length; i++) {
      try {
        float intVal = Float.valueOf(fingerStrings[i]);
        fingerState[i] = PApplet.lerp(fingerState[i], intVal, 0.2f);
      } 
      catch (Exception e) {
      }
    }

    // Calibrarte the values
    for (int i = 0; i < fingerStateCal.length; i++) {
      fingerStateCal[i] = PApplet.map(fingerState[i], 
      fingerCalibration[i][0], fingerCalibration[i][1], 0, 600);
    }

    float maxBending = 0;
    currentFinger = 99;
    for (int i = 0; i < fingerStateCal.length; i++) {
      if (fingerStateCal[i] > maxBending && fingerStateCal[i] > 300) {
        maxBending = fingerStateCal[i];
        currentFinger = i;
      }
    }
  }

  public void setPosition(PVector inputPos) {
    this.handPos = inputPos;
    this.pos = PVector.sub(inputPos, zeroPos);
  }

  public void setZeroPos(PVector handPos) {
    this.zeroPos = handPos;
  }

  public void draw() {
    pushStyle();
    switch (currentFinger) {
    case 0:
      stroke(255, 0, 0);
      break;
    case 1:
      stroke(0, 255, 0);
      break;
    case 2:
      stroke(0, 0, 255);
      break;
    case 3:
      stroke(255, 255, 0);
      break;
    case 5:
      stroke(255, 255, 255);
      break;
    }
    strokeWeight(20);
    if(!record)point(pos.x, pos.y, pos.z);
    popStyle();
  }

  public void drawData() {
    for (int i = 0; i < fingerStateCal.length; i++) {
      rect(0, 50 + i * 50, (int) fingerStateCal[i], 20);
    }
  }

  public void calibrateFinger(int i, int j) {
    fingerCalibration[i][j] = fingerState[i];
    saveCalibration();
  }

  private void saveCalibration() {
    String[] mySettings = new String[8];
    for (int k = 0; k < fingerCalibration.length; k++) {
      mySettings[k] = String.valueOf(fingerCalibration[k][0]);
      mySettings[k + 4] = String.valueOf(fingerCalibration[k][1]);
    }
    PApplet.saveStrings(fingerCal, mySettings);
  }

  private void getCalibration() {
    String[] mySettings = PApplet.loadStrings(fingerCal);
    for (int k = 0; k < fingerCalibration.length; k++) {
      fingerCalibration[k][0] = Float.valueOf(mySettings[k]);
      fingerCalibration[k][1] = Float.valueOf(mySettings[k + 4]);
    }
  }
}

