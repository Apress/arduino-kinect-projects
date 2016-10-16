float temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8,
temp9;


int servo3Pin = 3; //shoulder 1
int servo4Pin = 4; //arm 1
int servo5Pin = 5;//shoulder 2
int servo6Pin = 6;//arm 2
int servo7Pin = 7;// hip 1
int servo8Pin = 8;// leg 1
int servo9Pin = 9;// hip 2
int servo10Pin = 10; //leg 2
int servo11Pin = 11; //rotation

//initial pulse values
int pulse1 =500;
int pulse2 =1500;
int pulse3 =2500;
int pulse4 =1500;
int pulse5 =500;
int pulse6 =2500;
int pulse7 =2500;
int pulse8 =500;
int pulse9 =1500;

int speedServo = 0;

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

  Serial.begin(9600); // Start serial communication at 9600 bps
}

void loop() {

  if (Serial.available()>18) { // If data is available to read,
    char led=Serial.read();

    if (led=='S'){
      temp1 = Serial.read(); // read it and store it in values
      temp2 = Serial.read();
      temp3 = Serial.read();
      temp4 = Serial.read();
      temp5 = Serial.read();
      temp6 = Serial.read();
      temp7 = Serial.read();
      temp8 = Serial.read();
      temp9 = Serial.read();
    }
  }
//remaping between servo range
// according with processing sketch angles order are:
//rotation, left Elbow, left shoulder, left knee, left hip, right elbow, right shoulder, right knee, right hip
// we match each pulse with the right angle!!

pulse9 =  (int)map(temp1,0,255,2500,500);//rotation

pulse2 =  (int)map(temp2,0,255,500,2500);//leftElbow
pulse1 = (int)map(temp3,0,255,500,2500);//lef Shoulder
pulse4 =  (int)map(temp4,0,255,2500,500);//left Knee
pulse3 =  (int)map(temp5,0,255,500,2500);//left Hip
pulse6 =  (int)map(temp6,0,255,2500,500);//right Elbow
pulse5 = (int)map(temp7,0,255,2500,500);//right Shoulder
pulse8 =  (int)map(temp8,0,255,500,2500);//right Knee
pulse7 =  (int)map(temp9,0,255,2500,500);//right Hip
  
  


//move servo to the right position
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis; 

    updateServo(servo3Pin, pulse1);
    updateServo(servo4Pin, pulse2);
    updateServo(servo5Pin, pulse3);
    updateServo(servo6Pin, pulse4);
    updateServo(servo7Pin, pulse5);
    updateServo(servo8Pin, pulse6);
    updateServo(servo9Pin, pulse7);
    updateServo(servo10Pin,pulse8);
    updateServo(servo11Pin, pulse9);
  }
}

void updateServo (int pin, int pulse){
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
}

