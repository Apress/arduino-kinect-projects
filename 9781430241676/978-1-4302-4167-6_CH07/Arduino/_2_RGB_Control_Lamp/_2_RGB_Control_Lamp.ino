
int whiteLED = 5;
int redLED = 9;
int greenLED = 10;
int blueLED = 11;

int WVal, RVal, GVal, BVal;

int lampNumber = 0;

void setup() {

  Serial.begin(9600);
  
  // Set the pin modes
  pinMode(whiteLED, OUTPUT);
  pinMode(redLED, OUTPUT);
  pinMode(greenLED, OUTPUT);
  pinMode(blueLED, OUTPUT);
}

void loop(){

  // check if data has been sent from the computer:
  if (Serial.available()>5) { // If data is available to read,

   char val = Serial.read();

    if(val == 'S'){
      // read the most recent byte (which will be from 0 to 255):
      int messageNumber = Serial.read();
      if(messageNumber == lampNumber){
        WVal = Serial.read();
        RVal = Serial.read();
        GVal = Serial.read();
        BVal = Serial.read();
      }
    }    
  }
  analogWrite(whiteLED, WVal); 
  analogWrite(redLED, RVal); 
  analogWrite(greenLED, GVal); 
  analogWrite(blueLED, BVal); 
}





