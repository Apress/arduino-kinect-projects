public class Point {

  PVector pos;
  private boolean selected;

  Point(PVector pos) {
    this.pos = pos;
  }

  void draw() {
    pushStyle();
    strokeWeight(10);
    if (selected) {
      stroke(255, 255, 0);
    }
    else {
      stroke(200);
    }
    if (!record)point(pos.x, pos.y, pos.z);
    popStyle();
  }

  public void setPos(PVector newPos) {
    this.pos = newPos;
  }

  public void select() {
    this.selected = true;
  }
  public void unSelect() {
    this.selected = false;
  }
}

