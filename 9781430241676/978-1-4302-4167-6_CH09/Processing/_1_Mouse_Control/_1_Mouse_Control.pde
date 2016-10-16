import processing.serial.*;

Serial myPort;

boolean serial = false;

int Val01, Val02, Val03;
float temp01, temp02, temp03, temp04;

//car variables
int carwidth= 70;
int carheight =120;
int wheels=30;
float angle;
float speed, wLine, wLinePos;


void setup() {
  size(300, 300);
  smooth();

  if (serial) {
    String portName = Serial.list()[0]; // This gets the first port
    myPort = new Serial(this, portName, 9600);
  }
}

void draw() {
  background(255);
  PVector mouseL = new PVector(mouseX, mouseY);
  PVector centerL = new PVector(width/2, height/2);  

  //displacement between the centre and the mouse
  PVector v = PVector.sub(mouseL, centerL);

  //Draw  vector between 2 points
  drawVector(v, centerL);
  noFill();

  temp01 = mouseX-width/2;
  temp02 = height/2- mouseY;
  temp03= int(map(temp01, -width/2, width/2, 0, 255));

  //turn left
  if (temp03<100) {
    Val01=1;
    angle=-PI/4;
  } 
  //turn right 
  else if (temp03>150) {
    Val01=2;
    angle=PI/4;
  }
  //no turn
  else {     
    Val01=0;
    angle=0;
  }
  // decide where to move
  temp04= int(map(temp02, -height/2, height/2, -255, 250));

  //move front
  if (temp04>0 && temp04>50) {
    Val02=1;
  }
  //move back
  else if (temp04<0 && temp04<-50) {
    Val02=2;
  } 
  //don’t move
  else {
    Val02=0;
    speed=0;
  }

  //decide speed


  if (temp04>100 && temp04<150) {
    Val03=140;
    speed= speed+0.5;
  }
  else if (temp04>150) {
    Val03=200;
    speed++;
  }
  else if (temp04<-100 && temp04>-150) {
    Val03=140;
    speed= speed-0.5;
  }
  else if (temp04<-150) {
    Val03=200;
    speed--;
  }

  //println(Val01 + "   "  + Val02+ "   "  + Val03);

  ellipse(width/2, height/2, width/3, width/3);
  ellipse(width/2, height/2, width/6, width/6);

  car();
  if (serial) {
    sendSerialData();
  }
}


void drawVector(PVector v, PVector loc) {
  pushMatrix();
  float arrowsize = 4;
  translate(loc.x, loc.y);
  stroke(0);
  rotate(v.heading2D());
  float len = v.mag();
  line(0, 0, len, 0);
  line(len, 0, len-arrowsize, +arrowsize/2);
  line(len, 0, len-arrowsize, -arrowsize/2);
  popMatrix();
}


void car() {


  rectMode(CENTER);
  //body
  noFill();
  stroke(30, 144, 255);
  rect(width/2, height/2, carwidth-wheels/2, carheight);
  //front wheels

  pushMatrix();
  translate(width/2-carwidth/2+wheels/4, height/2-carheight/2+wheels);
  rotate(angle);
  rect(0, 0, wheels/2, wheels);
  popMatrix();
  pushMatrix();
  translate(width/2+carwidth/2-wheels/4, height/2-carheight/2+wheels);
  rotate(angle);
  rect(0, 0, wheels/2, wheels);
  popMatrix();

  //back wheels
  pushMatrix();
  translate(width/2, height/2);
  rect(-carwidth/2+wheels/4, carheight/4, wheels/2, wheels);
  rect(carwidth/2-wheels/4, carheight/4, wheels/2, wheels);
  //line simulating speed
  
  stroke(255, 0, 0);
  line(-carwidth/2, wLine, -carwidth/2+wheels/2, wLine);
  line(carwidth/2, wLine, carwidth/2-wheels/2, wLine);
  wLine=(carheight/4+wLinePos+speed);

  if (wLine<carheight/4-wheels/2) {
    wLine=carheight/4+wheels/2;
    speed=0;
    wLinePos=wheels/2;
  }
  else if (wLine>carheight/4+wheels/2) {
    wLine=carheight/4-wheels/2;
    speed=0;
    wLinePos=-wheels/2;
  }
  popMatrix();
}

void sendSerialData() {
  // Serial Communcation
  myPort.write('S');
  myPort.write(Val01);
  myPort.write(Val02);
  myPort.write(Val03);
}


