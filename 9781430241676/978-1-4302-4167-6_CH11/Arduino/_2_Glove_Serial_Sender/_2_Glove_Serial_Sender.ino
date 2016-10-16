#include <SoftwareSerial.h>

int finger1, finger2, finger3, finger4;

SoftwareSerial xbee(5,6);

void setup() {
  xbee.begin(9600);
}

void loop() {
  finger1 = analogRead(A5);
  finger2 = analogRead(A4);
  finger3 = analogRead(A3);
  finger4 = analogRead(A2);

  xbee.print(finger1);
  xbee.print(" "); 
  xbee.print(finger2);
  xbee.print(" "); 
  xbee.print(finger3);
  xbee.print(" "); 
  xbee.println(finger4);
}

