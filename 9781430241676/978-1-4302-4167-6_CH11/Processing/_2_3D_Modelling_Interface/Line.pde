public class Line {

  Point p1;
  Point p2;

  Line(Point p1, Point p2) {
    this.p1 = p1;
    this.p2 = p2;
  }

  void draw() {
    pushStyle();
    stroke(255);
    line(p1.pos.x, p1.pos.y, p1.pos.z, p2.pos.x, p2.pos.y, p2.pos.z);
    popStyle();
  }
}

