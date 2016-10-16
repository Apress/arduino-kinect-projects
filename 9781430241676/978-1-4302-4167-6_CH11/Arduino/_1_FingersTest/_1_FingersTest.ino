
int finger1, finger2, finger3, finger4;

void setup() {
  Serial.begin(9600);
}

void loop() {
  finger1 = analogRead(A5);
  finger2 = analogRead(A4);
  finger3 = analogRead(A3);
  finger4 = analogRead(A2);
  
  Serial.print(finger1);
  Serial.print(" "); 
  Serial.print(finger2);
  Serial.print(" "); 
  Serial.print(finger3);
  Serial.print(" "); 
  Serial.println(finger4);
}
