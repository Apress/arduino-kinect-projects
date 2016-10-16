
int val, xVal, yVal;
int sensorValue;

int sensorPin = 0;

void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  // initialize the serial communication:
  pinMode(10, OUTPUT);     
  pinMode(11, OUTPUT);  
}

void loop(){

  // Check Values from the Photocell
  sensorValue = analogRead(sensorPin); 
  
  Serial.println(sensorValue);
  // wait a bit for the analog-to-digital converter 
  // to stabilize after the last reading:
  delay(10);
  
  // check if data has been sent from the computer:
  if (Serial.available()>2) { // If data is available to read,

    val = Serial.read();

    if(val == 'S'){
      // read the most recent byte (which will be from 0 to 255):
      xVal = Serial.read();
      yVal = Serial.read();
    }    
  }
  analogWrite(10, xVal); 
  analogWrite(11, yVal); 
}




