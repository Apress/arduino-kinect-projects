
void setup() {
  
  pinMode(2, OUTPUT); // Set the digital pin as an output.
}

void loop() {
  
  digitalWrite(2, HIGH); // set the LED on
  delay(1000); // wait for a second
  digitalWrite(2, LOW); // set the LED off
  delay(1000); // wait for a second
  
}

