int whiteLED = 5;
int redLED = 9;
int greenLED = 10;
int blueLED = 11;

int Wbr = 0;
int Rbr = 0; 
int Gbr = 0; 
int Bbr = 0; 

int Wspeed = 0;
int Rspeed = 2;
int Gspeed = 3;
int Bspeed = 5;

void setup()  { 

  pinMode(whiteLED, OUTPUT);
  pinMode(redLED, OUTPUT);
  pinMode(greenLED, OUTPUT);
  pinMode(blueLED, OUTPUT);

} 

void loop()  { 

  analogWrite(whiteLED, Wbr);
  analogWrite(redLED, Rbr);
  analogWrite(greenLED, Gbr);
  analogWrite(blueLED, Bbr);

  Wbr +=  Wspeed;
  if (Wbr == 0 || Wbr == 255) {
    Wspeed *= -1 ; 
  } 

  Rbr +=  Rspeed;
  if (Rbr == 0 || Rbr == 255) {
    Rspeed *= -1 ; 
  } 
  Gbr +=  Gspeed;
  if (Gbr == 0 || Gbr == 255) {
    Gspeed *= -1 ; 
  } 

  Bbr +=  Bspeed;
  if (Bbr == 0 || Bbr == 255) {
    Bspeed *= -1 ; 
  } 

  delay(30);
}


