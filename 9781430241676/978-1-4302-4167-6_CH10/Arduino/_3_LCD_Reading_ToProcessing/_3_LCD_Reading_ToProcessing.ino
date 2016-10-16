#define dataSize 13
int data [dataSize];
int previousData [dataSize];
#define lines 4
int serial [lines][dataSize];
int index;
// Booleans defining the change
boolean changed;
boolean scanning;
boolean start;

int state;
int previousState;

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
  data[12] = digitalRead(A2);

  state = analogRead(A0);

  // Check if the numbers have changed from the previous reading
  int same = 0;
  for(int i = 0; i<dataSize; i++){
    if(data[i]==previousData[i])same++;
    previousData[i] = data[i];
  }

  if(same<dataSize){
    changed=true;
    scanning=true;
  }
  else{
    changed=false;
  }

  if(changed == false && scanning == true){
    if(data[1] == 1){
      start=false;
      Serial.println('S');
      for(int i = 0; i<4; i++){
        for(int j = 0; j<dataSize; j++){
          Serial.print(serial[i][j]);
        }
        Serial.println();
      }
      Serial.print('X');
      Serial.println(state);
    }
    
    if(start){
      for(int i = 0; i<dataSize; i++){
        char number[1];
        // Serial.print(itoa(data[i], number, 10));
        //        Serial.print(" ");
        serial[index][i]=data[i];
      }
      index++;
    }
    scanning=false;

    if(data[3] == 1){
      start=true;
      index = 0;
    }
  }
}



