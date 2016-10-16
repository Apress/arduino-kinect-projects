int servo3Pin = 3;
int servo4Pin = 4;
int servo5Pin = 5;
int servo6Pin = 6;
int servo7Pin = 7;
int servo8Pin = 8;
int servo9Pin = 9;
int servo10Pin = 10;
int servo11Pin = 11;

int servoPulse = 500;
int servoPulse2 = 1500;
int servoPulse3 = 2500;
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
    updateServo(servo3Pin, servoPulse);//lef Shoulder
    updateServo(servo4Pin, servoPulse2);//left Elbow
    updateServo(servo5Pin, servoPulse);//left Hip
    updateServo(servo6Pin, servoPulse2);//left Knee
    updateServo(servo7Pin, servoPulse3); //right Shoulder
    updateServo(servo8Pin, servoPulse2);//rigt Elbow
    updateServo(servo9Pin, servoPulse3);// right Hip
    updateServo(servo10Pin, servoPulse2);//right Knee
    updateServo(servo11Pin, servoPulse2);//move it to the central position
    
  }
}

void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}

