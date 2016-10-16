import processing.opengl.*;

void setup()
{
  size(800, 600, OPENGL);
}

void draw()
{
  background(255);
  noFill();
  translate(width/2, height/2);
  box(200);
}

