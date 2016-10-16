// Remote Control

//Use of 4 pins, 2 for channel changes, 2 volume changes
int ChannelPlusPin = 5;
int ChannelLessPin = 6;
int VolumePlusPin = 7;
int VolumeLessPin = 8;


int pulse = 250;   // milliseconds to hold button on


void setup()
{
  //set up pins as outputs
  
  pinMode(ChannelPlusPin, OUTPUT);
  pinMode(ChannelLessPin, OUTPUT);
  pinMode(VolumePlusPin, OUTPUT);
  pinMode(VolumeLessPin, OUTPUT);
  
  Serial.begin(9600);// Start serial communication at 9600 bps

}

void loop()
{
   if (Serial.available()) { // If data is available to read,
    char val=Serial.read();

    if(val == '1') {
      // Channel plus button pulsed
      updatePin(ChannelPlusPin, pulse);
    } else if(val == '2') {
      // Channel less button pulsed
     updatePin(ChannelLessPin, pulse);
    } else if(val == '3') {
      // Volume plus button pulsed
    updatePin(VolumePlusPin, pulse);
    } else if(val == '4') {
      // Volume less button pulsed
   updatePin(VolumeLessPin, pulse);
    } 
  }
}

// function for updating any pin

void updatePin (int pin, int pulse){
  Serial.print("RECEIVED PIN");
  Serial.println(pin);	
  digitalWrite(pin, HIGH);
  delayMicroseconds(pulse);
  digitalWrite(pin, LOW);
  Serial.println("OFF");
}

