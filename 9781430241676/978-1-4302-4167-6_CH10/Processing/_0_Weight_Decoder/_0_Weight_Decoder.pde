import processing.serial.*;

Serial myPort;
PFont font;
LCD lcd;

char[][] stringData = new char[4][13];
int currentLine;

public void setup() {
  size(400, 300);
  font = loadFont("SansSerif-14.vlw");
  textFont(font);
  
  String portName = Serial.list()[0]; // This gets the first port on your computer.
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  lcd = new LCD();
}

public void draw() {
  background(0);
  
  lcd.setLcdArray(stringData);
  lcd.displayArray(50, 50);
  
  text(lcd.data + " " + lcd.units, 50, 200);
}

public void serialEvent(Serial myPort) {
  
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
      if (inString.length() == 13 && currentLine<4) {
        for (int i = 0; i < stringData[0].length; i++) {
          stringData[currentLine][i] = inString.charAt(i);
        }
        currentLine++;
      }
    }
  }
  else {
    // increment the horizontal position:
    println("No data to display");
  }
}

