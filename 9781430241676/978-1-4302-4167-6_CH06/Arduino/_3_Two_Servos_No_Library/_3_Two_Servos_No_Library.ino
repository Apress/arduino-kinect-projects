int servo1Pin = 5;
int servo2Pin = 6;
unsigned long previousMillis = 0;
long interval = 20;   

void setup() {
  pinMode (servo1Pin, OUTPUT);
  pinMode (servo2Pin, OUTPUT);
}

void loop() {
  int pot = analogRead(0); // Read the potentiometer
  int servo1Pulse = map(pot,0,1023,1000,2000);
  int servo2Pulse = map(pot,0,1023,1500,2000);

  // Update servo only if 20 milliseconds have elapsed since last update
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;  
    updateServo(servo1Pin, servo1Pulse);
    updateServo(servo2Pin, servo2Pulse);
  }
}

void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}

