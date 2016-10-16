int servo3Pin = 3;
int servo4Pin = 4;
int servo5Pin = 5;
int servo6Pin = 6;
int servo7Pin = 7;
int servo8Pin = 8;
int servo9Pin = 9;
int servo10Pin = 10;
int servo11Pin = 11;

int servoPulse = 1500;
int speedServo = 50;

unsigned long previousMillis = 0;
long interval = 20;   

void setup() {
  
  pinMode (servo3Pin, OUTPUT);
  pinMode (servo4Pin, OUTPUT);
  pinMode (servo5Pin, OUTPUT);
  pinMode (servo6Pin, OUTPUT);
  pinMode (servo7Pin, OUTPUT);
  pinMode (servo8Pin, OUTPUT);
  pinMode (servo9Pin, OUTPUT);
  pinMode (servo10Pin, OUTPUT);
  pinMode (servo11Pin, OUTPUT);
}

void loop() {
  

  // Update servo only if 20 milliseconds have elapsed since last update
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;  
    updateServo(servo3Pin, servoPulse);
    updateServo(servo4Pin, servoPulse);
    updateServo(servo5Pin, servoPulse);
    updateServo(servo6Pin, servoPulse);
    updateServo(servo7Pin, servoPulse);
    updateServo(servo8Pin, servoPulse);
    updateServo(servo9Pin, servoPulse);
    updateServo(servo10Pin, servoPulse);
    updateServo(servo11Pin, servoPulse);
    
    
     servoPulse += speedServo;
     if(servoPulse > 2500 || servoPulse <500){
     speedServo *= -1;
    }
  }
}

void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}

