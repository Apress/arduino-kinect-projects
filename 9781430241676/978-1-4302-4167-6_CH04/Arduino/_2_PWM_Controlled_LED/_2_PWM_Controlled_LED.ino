void setup() {
  Serial.begin(9600);
  pinMode(11, OUTPUT);
}
void loop(){
  if (Serial.available()) { // If data is available to read,
    int input=Serial.read();
    analogWrite(11, input);
  }
}

