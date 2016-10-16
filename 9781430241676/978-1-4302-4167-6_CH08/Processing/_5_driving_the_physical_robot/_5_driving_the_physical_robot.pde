import processing.serial.*;
import cc.arduino.*;
Arduino arduino;

int servo1pin = 11;
int servo2pin = 10;
int servo3pin = 9;

float angle1 = 0; //declaration of all 3 angles for servos
float angle2 = 0; 
float angle3 = 0;
void setup(){
size (800, 600);
arduino = new Arduino(this, Arduino.list()[0]);
arduino.pinMode(servo1pin, Arduino.OUTPUT);
arduino.pinMode(servo2pin, Arduino.OUTPUT);
arduino.pinMode(servo3pin, Arduino.OUTPUT);
}

void draw(){
  background(255);
  translate(width/2, 0); 
  
  float penX = mouseX-width/2;
  float penY = mouseY;
  
  ellipse(penX, penY, 20,20);
  ellipse(0, 0, 20, 20);
  
  line(0, 0, penX, penY);
  float len = dist(0, 0, penX, penY); //let's measure the length of our line
  float angle = asin(penY/len); 
  if (penX < 0) { angle = PI - angle; }
  
  println("angle = " + degrees(angle)); //we're outputting angle value converted from radians to degrees
  println("length = " + len);//print out the length 
  arc(0,0,200,200, 0, angle); //let's draw our angle as an arc
  if (len > 450) { len = 450; }
  if (len < 150) { len = 150; }
  
  float dprim = (len - 150)/2.0;
  float a = acos(dprim/150);
  angle3 = angle + a;
  angle2 = -a;
  angle1 = -a;
  
  rotate(angle3);
  line(0, 0, 150, 0);
  translate(150, 0);
  
  rotate(angle2);
  line(0, 0, 150, 0);
  translate(150, 0);
  
  rotate(angle1);
  line(0, 0, 150, 0);
  translate(150, 0);

// The following lines will make use of the Arduino library to send the values of the angles to the Arduino board.

  arduino.analogWrite(servo1pin, 90-round(degrees(angle1))); // move servo 1
  arduino.analogWrite(servo2pin, 90-round(degrees(angle2))); // move servo 2
  arduino.analogWrite(servo3pin, round(degrees(angle3))); // move servo 3  
}

