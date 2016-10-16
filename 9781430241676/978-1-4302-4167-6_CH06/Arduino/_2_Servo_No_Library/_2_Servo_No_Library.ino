int servoPin = 5;
unsigned long previousMillis = 0;
long interval = 20;   

void setup() {
  pinMode (servoPin, OUTPUT);
}

void loop() {
  int pot = analogRead(0); // Read the potentiometer
  int servoPulse = map(pot,0,1023,500,2500);

  // Update servo only if 20 milliseconds have elapsed since last update
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;  
    updateServo(servoPin, servoPulse);
  }
}

void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}

