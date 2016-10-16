
float Val01, Val02, Val03, Val04;

int motorFrontLeft = 11;   // H-bridge leg 10
int motorFrontRight = 5;  // H-bridge leg 15 
int motorBackUp = 6;     // H-bridge leg 2 (PWM)
int motorBackDown = 10;  // H-bridge leg 7 (PWM)
int enablePinFront = 8; // H-Bridge leg 9
int enablePinBack = 9; // H-Bridge leg 1

int sensorPin =  0;
int sensorValue=0;
int Value =500; //threshold for detecting object



void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  // Set the pin modes
  pinMode(motorFrontLeft, OUTPUT); 
  pinMode(motorFrontRight, OUTPUT); 
  pinMode(motorBackUp, OUTPUT);
  pinMode(motorBackDown, OUTPUT);
  pinMode (enablePinFront, OUTPUT);
  pinMode(enablePinBack, OUTPUT);
 
}

void loop() {
  // check if data has been sent from the computer:
  if (Serial.available()>5) { // If data is available to read,

    char val = Serial.read();

    if(val == 'S'){

      Val01 = Serial.read();
      Val02 = Serial.read();
      Val03 = Serial.read();
      Val04 = Serial.read();
    }
  }
  //reading data form sensor
if (Val04= 1)sensorValue = analogRead(sensorPin);
else sensorValue=0;

  // turning left and right
  if (sensorValue<Value){
    if (Val01==1){
      enable(enablePinFront);
      TurnRight();
    }
    else if (Val01==2){
      enable(enablePinFront);
      TurnLeft();
    }
    else if(Val01==0)disable(enablePinFront);


    if (Val02==1){
      enable(enablePinBack);
      MoveUp(Val03);
    }
    else if (Val02==2){
      enable(enablePinBack);
      MoveDown(Val03);
    }
    else if(Val02==0)disable(enablePinBack);
  }
  else{
    enable(enablePinBack);
    stopCar(); 
  }
}

//function to turn Right
void TurnRight(){
  digitalWrite(motorFrontRight,HIGH);
  digitalWrite(motorFrontLeft,LOW);
}

//function to turn Left
void TurnLeft(){
  digitalWrite(motorFrontLeft,HIGH);
  digitalWrite(motorFrontRight,LOW);
}
//function to move
void MoveUp(int speedD){
  analogWrite(motorBackUp,speedD);
  analogWrite(motorBackDown,0);
}
//function to move reverse
void MoveDown(int speedD){
  analogWrite(motorBackDown,speedD);
  analogWrite(motorBackUp,0);
}
void enable(int pin){
  digitalWrite(pin, HIGH);
}

void disable(int pin){
  digitalWrite(pin, LOW);
}


void stopCar(){
for(int i=0; i<2000; i++){
    MoveDown(200);
}
    disable(enablePinBack);   
}

