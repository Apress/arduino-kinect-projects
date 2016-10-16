import processing.serial.*;
Serial myPort;

void setup()
{
  size(255, 255);
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  // Create a gradient for visualisation
  for (int i = 0; i<width; i++) {
    stroke(i);
    line(i, 0, i, height);
  }
  // Send the value of the mouse's x-position
  myPort.write(mouseX);
}

