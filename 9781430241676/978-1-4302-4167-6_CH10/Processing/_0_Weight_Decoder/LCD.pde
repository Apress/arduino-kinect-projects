public class LCD {

  private float data;
  int lcdArray[][] = new int[4][13];
  private String units = "kg";
  private int state;

  boolean foundWeight;
  boolean scanning;

  int[] zero = { 
    1, 1, 1, 0, 1, 1, 1
  };
  int[] one = { 
    0, 0, 1, 0, 1, 0, 0
  };
  int[] two = { 
    1, 1, 0, 1, 1, 0, 1
  };
  int[] three = { 
    1, 0, 1, 1, 1, 0, 1
  };
  int[] four = { 
    0, 0, 1, 1, 1, 1, 0
  };
  int[] five = { 
    1, 0, 1, 1, 0, 1, 1
  };
  int[] six = { 
    1, 1, 1, 1, 0, 1, 1
  };
  int[] seven = { 
    0, 0, 1, 0, 1, 1, 1
  };
  int[] eight = { 
    1, 1, 1, 1, 1, 1, 1
  };
  int[] nine = { 
    1, 0, 1, 1, 1, 1, 1
  };

  public float getReading() {
    return data;
  }

  public void setLcdArray(char[][] stringData) {
    if (stringData[1][12] == '1') {
      units = "kg";
    }
    else if (stringData[2][12] == '1') {
      units = "lb";
    }
    for (int i = 0; i < stringData.length; i++) {
      for (int j = 0; j < stringData[0].length; j++) {
        lcdArray[i][j] = Character.digit(stringData[i][j], 10);
      }
    }
    this.update();
  }

  public void update() {
    int[] digits = new int[4];
    int[][][] segments = new int[4][4][2];
    for (int i = 0; i < lcdArray.length; i++) {
      for (int j = 4; j < 6; j++) {
        segments[0][i][j - 4] = lcdArray[i][j];
      }
      for (int j = 6; j < 8; j++) {
        segments[1][i][j - 6] = lcdArray[i][j];
      }
      for (int j = 8; j < 10; j++) {
        segments[2][i][j - 8] = lcdArray[i][j];
      }
      for (int j = 10; j < 12; j++) {
        segments[3][i][j - 10] = lcdArray[i][j];
      }
    }

    for (int i = 0; i < digits.length; i++) {
      digits[i] = getNumber(segments[i]);
    }
    data = digits[0] * 100 + digits[1] * 10 + digits[2] + digits[3] * 0.1;
  }

  public int getNumber(int segments[][]) {
    int flatSegment[] = new int[7];
    for (int i = 0; i < segments.length; i++) {
      for (int j = 0; j < segments[0].length; j++) {
        if (i + j == 0) {
          flatSegment[i * 2 + j] = segments[i][j];
        }
        else if (!(i == 0 && j == 1)) {
          flatSegment[i * 2 + j - 1] = segments[i][j];
        }
      }
    }
    if (Arrays.equals(flatSegment, zero)) { 
      return 0;
    }
    else if (Arrays.equals(flatSegment, one)) { 
      return 1;
    }
    else if (Arrays.equals(flatSegment, two)) { 
      return 2;
    }
    else if (Arrays.equals(flatSegment, three)) { 
      return 3;
    }
    else if (Arrays.equals(flatSegment, four)) { 
      return 4;
    }
    else if (Arrays.equals(flatSegment, five)) { 
      return 5;
    }
    else if (Arrays.equals(flatSegment, six)) { 
      return 6;
    }
    else if (Arrays.equals(flatSegment, seven)) { 
      return 7;
    }
    else if (Arrays.equals(flatSegment, eight)) { 
      return 8;
    }
    else if (Arrays.equals(flatSegment, nine)) { 
      return 9;
    }
    else {
      return 0;
    }
  }

  public void setState(int state) {
    this.state = state;
    if (state < 518 && state > 513) {
      scanning = true;
    }
    if (state < 531 && state > 526 && scanning) {
      foundWeight = true;
    }
  }

  public void displayArray(int x, int y) {
    pushMatrix();
    translate(x, y);
    for (int i = 0; i < lcdArray[0].length; i++) {
      for (int j = 0; j < lcdArray.length; j++) {
        text(lcdArray[j][i], 20 * i, j * 20);
      }
    }
    popMatrix();
  }
}

