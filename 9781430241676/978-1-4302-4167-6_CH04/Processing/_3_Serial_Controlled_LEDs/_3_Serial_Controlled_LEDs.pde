import processing.serial.*;
Serial myPort;

void setup()
{
  size(255, 255);

  String portName = Serial.list()[0]; // This gets the first port on your computer.
  myPort = new Serial(this, portName, 9600);
}
void draw() {

  // Create a gradient for visualisation
  for (int i = 0; i<width; i++) {
    for (int j = 0; j<height; j++) {

      color myCol = color(i, j, 0);
      set(i, j, myCol);
    }
  }

  // Send an event trigger character to indicate the beginning of the communication
  myPort.write('S');
  // Send the value of the mouse's x-position
  myPort.write(mouseX);
  // Send the value of the mouse's y-position
  myPort.write(mouseY);
}

