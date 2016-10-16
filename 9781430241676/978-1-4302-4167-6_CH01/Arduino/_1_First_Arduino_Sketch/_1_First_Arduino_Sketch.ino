
int ledPin = 11;

void setup() {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);  
}

void loop() {
  int sensorValue = analogRead(A0);
  Serial.println(sensorValue);
  
  int ledBrightness = map(sensorValue,0,1023,0,255);
  analogWrite(ledPin, ledBrightness);
}
