int ledPin = 13;

void setup() {
  pinMode(ledPin, OUTPUT);
  int myOtherPin = 6;
  pinMode(myOtherPin, OUTPUT);
}

void loop() {
  digitalWrite(ledPin, HIGH); // set the LED on
  delay(1000); // wait for a second
  digitalWrite(ledPin, LOW); // set the LED off
  delay(1000); // wait for a second
}


