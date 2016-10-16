
unsigned int tempHandRot, tempGrip;
unsigned int servo1Pos, servo2Pos, servo3Pos;

int ledPin = 3;

int servo1Pin = 9;
int pulse1 = 1500;

int servo2Pin = 10;
int pulse2 = 1500;

int servo3Pin = 11;
int pulse3 = 1500;

int handRotPin = 5;
int handRotPulse = 1500;

int gripPin = 6;
int gripPulse = 1500;

long previousMillis = 0;
long interval = 20;   

int speedServo1 = 0;
int speedServo2 = 0;
int speedServo3 = 0;

int handRotSpeed = 20;
int gripSpeed = 20;

void setup() {
  pinMode (ledPin, OUTPUT);
  pinMode (servo1Pin, OUTPUT);
  pinMode (servo2Pin, OUTPUT);
  pinMode (servo3Pin, OUTPUT);
  pinMode (handRotPin, OUTPUT);
  pinMode (gripPin, OUTPUT);

  Serial.begin(9600); // Start serial communication at 9600 bps

}

void loop() {
  
  digitalWrite(ledPin, HIGH);

  if (Serial.available()>8) { // If data is available to read,

    char led=Serial.read();

    if (led=='X'){
      
      byte MSB1 = Serial.read();
      byte LSB1 = Serial.read();
      servo1Pos = word(MSB1, LSB1);
      
      byte MSB2 = Serial.read();
      byte LSB2 = Serial.read();
      servo2Pos = word(MSB2, LSB2);
      
      byte MSB3 = Serial.read();
      byte LSB3 = Serial.read();
      servo3Pos = word(MSB3, LSB3);
      
      tempHandRot = Serial.read();
      tempGrip = Serial.read(); 
    }
  }

  pulse1 = (int)map(servo1Pos,0,2000,500,2500);
  pulse2 =  (int)map(servo2Pos,0,2000,500,2500);
  pulse3 =  (int)map(servo3Pos,0,2000,500,2500);
  
  handRotPulse =  (int)map(tempHandRot,0,200,2500,500);
  gripPulse =  (int)map(tempGrip,0,220,500,2500);
  
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;   

    updateServo(servo1Pin, pulse1);
    updateServo(servo2Pin, pulse2);
    updateServo(servo3Pin, pulse3);
    updateServo(handRotPin, handRotPulse);
    updateServo(gripPin, gripPulse);

  }
}

void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}

