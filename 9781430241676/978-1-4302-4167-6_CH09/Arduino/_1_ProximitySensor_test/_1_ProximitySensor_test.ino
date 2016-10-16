int sensorPin = 0; //analog pin 0

void setup(){
  Serial.begin(9600);
}

void loop(){
  int val = analogRead(sensorPin);
  //float val = 12343.85 * pow(analogRead(sensorPin),-1.15);
  Serial.println(val);

  //just to slow down the output - remove if trying to catch an object passing by
  delay(100);

}
