#define dataSize 16
int data [dataSize];

void setup() {
  Serial.begin(9600);
  pinMode(2,INPUT);
  pinMode(3,INPUT);
  pinMode(4,INPUT);
  pinMode(5,INPUT);
  pinMode(6,INPUT);
  pinMode(7,INPUT);
  pinMode(8,INPUT);
  pinMode(9,INPUT);
  pinMode(10,INPUT);
  pinMode(11,INPUT);
  pinMode(12,INPUT);
}

void loop() {

  for(int i = 2; i<13; i++){
    data[i-2] = digitalRead(i); 
  }
  data[11] = digitalRead(A5);
  data[12] = digitalRead(A4);
  data[13] = digitalRead(A3);
  data[14] = digitalRead(A2);
  data[15] = digitalRead(A1);

  for(int i = 0; i<dataSize; i++){
    Serial.print(data[i]);
  }

}

