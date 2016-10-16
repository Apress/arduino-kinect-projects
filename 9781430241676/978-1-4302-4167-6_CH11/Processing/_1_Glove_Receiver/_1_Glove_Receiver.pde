import processing.serial.*;

// Serial Parameters
Serial myPort; // Initialize the Serial Object
float[] fingerData = new float[4];

void setup() {

  size(800, 300);

  // Serial Communication
  String portName = Serial.list()[0]; // Get the first port
  myPort = new Serial(this, portName, 9600);
  // don't generate a serialEvent() unless you get a newline
  myPort.bufferUntil('\n');
}

void draw() {

  background(0); 

  for (int i = 0; i < fingerData.length; i++) {
    rect(0, 50+i*50, fingerData[i], 20);
  }
}

public void serialEvent(Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    String[] fingerStrings = inString.split(" ");
    if (fingerStrings.length==4) {
      for (int i = 0; i < fingerData.length; i++) {
        try {
          float intVal = Float.valueOf(fingerStrings[i]);
          fingerData[i] = lerp(fingerData[i], intVal, 0.5);
        } 
        catch (Exception e) {
        }
      }
    }
  }
}

