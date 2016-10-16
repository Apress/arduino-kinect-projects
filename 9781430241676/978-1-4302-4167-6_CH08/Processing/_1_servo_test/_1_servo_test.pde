import processing.serial.*;
import cc.arduino.*; 

Arduino arduino;
int servoPin = 11; // Control pin for servo motor
void setup(){
  size (180, 100);
  arduino = new Arduino(this, Arduino.list()[0]);
  arduino.pinMode(servoPin, Arduino.OUTPUT);
}

void draw(){
  arduino.analogWrite(servoPin, mouseX); // the servo moves to the horizontal location of the mouse
}

