int servoPin = 6;
int potPin = 0;

long previousMillis = 20;
long interval = 20;   
int servoPulse = 1500; 

// Start and end values from potentiometer (0-360 degrees)
int startPos = 100;
int endPos = 824;

// Forward and backward pulses
int forward = 1000;
int backward = 2000;

int state = 1;    // State of the motor
int targetAngle = startPos;  // Target Angle
int potAngle;     // Current angle of the potentiometer

void setup(){
  Serial.begin(9600);
  pinMode (servoPin, OUTPUT);
}

void loop() {    


  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    // Update servo only if 20 milliseconds have elapsed since last update
    previousMillis = currentMillis;  

    potAngle = analogRead(0);  // Read the potentiometer
    Serial.println(potAngle);  // Send the pot value to Processing

    if(potAngle < startPos){  // If we have
      state = 0;
      updateServo(servoPin,forward);
      Serial.println("start");
    } 
    if(potAngle > endPos){
      state = 0;
      updateServo(servoPin,backward);
      Serial.println("end");
    }

    checkSerial();  // Check for values in the serial buffer

    if(state==1){
      goTo(targetAngle);
    }
  }

}

void goTo(int angle){
  if(potAngle-angle<-10){
    updateServo(servoPin,forward);
  }
  else if(potAngle-angle>10){
    updateServo(servoPin,backward);
  }
  else {
    Serial.println("arrived");
    state=0;
  }
}

void checkSerial(){
  if (Serial.available()>1) { // If data is available to read,

    char trigger = Serial.read();

    if(trigger=='S'){
      state = 1;
      int newAngle = Serial.read();
      targetAngle = (int)map(newAngle,0,255,startPos,endPos);
    }
  }
}


void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}









