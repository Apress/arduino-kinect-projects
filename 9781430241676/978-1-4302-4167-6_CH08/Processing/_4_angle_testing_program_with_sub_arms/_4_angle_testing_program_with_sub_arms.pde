float angle1 = 0; 
float angle2 = 0; 
float angle3 = 0;

//servo robot testing program
void setup(){
size (800, 600);
}

void draw(){
  background(255);
  translate(width/2, 0); //we need to center our X coordinates to the middle of the screen
  float penX = mouseX - width/2; //we're capturing coordinates of our pen tip (mouse)
  float penY = mouseY;
  ellipse(penX, penY, 20,20);
  ellipse(0,0, 20,20);
  
  line(0,0, penX, penY);
  float len = dist(0,0, penX, penY); //let's measure the length of our line
  float angle = asin(penY/len); //asin returns angle value in range of 0 to PI/2, in radians
  if (penX<0) { angle = PI - angle; }  // this line makes sure angle is greater than PI/2 (90 deg) when penX is negative
  println("angle = " + degrees(angle)); //we're outputting angle value converted from radians to degrees
  println("length = " + len);//print out the length 
  arc(0,0,200,200, 0, angle); //let's draw our angle as an arc
  if (len>450) len = 450;
  if (len<150) len = 150;
  
  float dprime = (len - 150)/2.0;
  float a = acos(dprime/150);
  angle1 = angle + a;
  angle2 =  - a;
  angle3 =  - a;
  
  rotate(angle1);
  line(0,0,150,0);
  translate(150,0);
  
  rotate(angle2);
  line(0,0,150,0);
  translate(150,0);
  
  rotate(angle3);
  line(0,0,150,0);
  translate(150,0);
  
}

