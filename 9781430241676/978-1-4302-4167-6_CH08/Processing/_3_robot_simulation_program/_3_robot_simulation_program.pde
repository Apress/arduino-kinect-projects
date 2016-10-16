void setup() {
  size (800, 600);
}

void draw() {
  background(255);
  //We first need to center our X coordinate in the middle of the screen.
  translate(width/2, 0); 
  // Then, we will be capturing the coordinates of our pen tip (mouse).
  float penX = mouseX - width/2; 
  float penY = mouseY;

  ellipse(penX, penY, 20, 20);//draw pen tip
  ellipse(0, 0, 20, 20);

  line(0, 0, penX, penY);
  float len = dist(0, 0, penX, penY); //let's measure the length of our line
  //  The asin() function will return an angle value in range of 0 to PI/2, in radians. The following line will make sure that the angle is greater than PI/2 (90 degrees) when penX is negative.
  float angle = asin(penY/len);
  if (penX < 0) { 
    angle = PI - angle;
  }
  // We will then be outputting the angle value converted from radians to degrees
  println("angle = " + degrees(angle)); 
  println("length = " + len);//print out the length 
  // And finally, we’ll draw our angle as an arc.
  arc(0, 0, 200, 200, 0, angle); 

  // constrain the length to the physical size of the robot’s parts

  if (len > 450) { 
    len = 450;
  }
  if (len < 150) { 
    len = 150;
  }

  // calculate your three servo angles.

  float dprime =  (len - 150) / 2.0;
  float a = acos(dprime / 150);
  float angle1 = angle + a;
  float angle2 = -a;
  float angle3 = -a;

  // and finally, use the angles to draw the robot on screen. 

  rotate(angle1);
  line(0, 0, 150, 0);
  translate(150, 0);

  rotate(angle2);
  line(0, 0, 150, 0);
  translate(150, 0);

  rotate(angle3);
  line(0, 0, 150, 0);
  translate(150, 0);
}

