import processing.net.*;

PFont font;
Client c;
String input;
float data[] = new float[9];

PShape s;
float lAngle, rAngle;

void setup() 
{
  size(640, 700);
  background(255);
  stroke(0);
  frameRate(10); // Slow it down a little
  // Connect to the server's IP address and port
  c = new Client(this, "127.0.0.1", 12345); // Replace with your server's IP and port

  font = loadFont("SansSerif-14.vlw"); 
  textFont(font);
  textAlign(CENTER);

  s = loadShape("Android.svg");
  shapeMode(CENTER);
  smooth();
}

void draw() 
{
  background(0);

  // Receive data from server
  if (c.available() > 0) {
    input = c.readString();
    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
    data = float(split(input, ' ')); // Split values into an array
    // Draw line using received coords
  }

  // translate(width/2, height/2);
  //scale(map(data[0],0,2*PI,-1,1), 1);

  shape(s, 300, 100, 400, 400);

  drawLimb(150, 210, PI, data[2], data[1], 50);
  drawLimb(477, 210, 0, data[6], data[5], 50);
  drawLimb(228, 385, PI/2, data[4], data[3], 60);
  drawLimb(405, 385, PI/2, data[8], data[7], 60);

  stroke(200);
  fill(200);
  for (int i = 0; i < data.length; i++) {
    pushMatrix();
    translate(50+i*65, height/1.2);
    noFill();
    ellipse(0, 0, 60, 60);
    text("Servo " + i + "\n" + round(degrees(data[i])), 0, 55); 
    rotate(data[i]);
    line(0, 0, 30, 0);
    popMatrix();
  }
}

void drawLimb(int x, int y, float angle0, float angle1, float angle2, float limbSize) {
  pushStyle();
  strokeCap(ROUND);
  strokeWeight(62);
  stroke(134, 189, 66);
  pushMatrix();
  translate(x, y);
  rotate(angle0);
  rotate(angle1);
  line(0, 0, limbSize, 0);
  translate(limbSize, 0);
  rotate(angle2);
  line(0, 0, limbSize, 0);
  popMatrix();
  popStyle();
}
void mousePressed() {
  println(mouseX);
  println(mouseY);
}

