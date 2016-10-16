public class Lamp {

  PVector pos;
  int R, G, B, W;

  Lamp(float x, float y, float z) {
    this.pos = new PVector(x, y, z);
    this.B = 255;
  }

  public void setColor(int r, int g, int b) {
    R = r;
    G = g;
    B = b;
  }

  public int[] getColor() {
    int[] colors = { R, G, B };
    return colors;
  }

  public void setPos(PVector pos) {
    this.pos = pos;
  }

  public void draw() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    pushStyle();
    if (W == 255) {
      fill(W);
    } 
    else {
      fill(R, G, B);
    }
    noStroke();
    box(100, 150, 100);
    popStyle();
    popMatrix();
  }

  public void updateUserPos(PVector userCenter) {
    float dist = pos.dist(userCenter);
    if (dist < 1000) {
      W = 255;
    } 
    else {
      W = 0;
    }
    stroke(200);
    line(pos.x, pos.y, pos.z, userCenter.x, userCenter.y, userCenter.z);
  }

  public void drawSelected() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    pushStyle();
    noFill();
    stroke(R, G, B);
    box(150, 225, 150);
    // point(pos.x, pos.y, pos.z);
    popStyle();
    popMatrix();
  }
}

