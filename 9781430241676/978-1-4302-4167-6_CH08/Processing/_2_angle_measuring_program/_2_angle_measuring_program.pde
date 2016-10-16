void setup() {
  size (800, 600);
}
void draw() {
  background(255);
  translate(width/2, 0);
  float penX = mouseX - width/2;
  float penY = mouseY;
  ellipse(penX, penY, 20, 20);//draw pen tip

  ellipse(0, 0, 20, 20);
  line(0, 0, penX, penY);
  float len = dist(0, 0, penX, penY); //let's measure the length of your line

  float angle = asin(penY/len);
  if (penX < 0) { 
    angle = PI - angle;
  }
  println("angle = " + degrees(angle));
  println("length = " + len);//print out the length
  arc(0, 0, 200, 200, 0, angle);
}

