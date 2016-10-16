public class Shape {

  ArrayList<Point> points = new ArrayList<Point>();

  Shape( ArrayList<Point> points) {
    for (Point pt : points) {
      this.points.add(pt);
    }
  }

  void draw() {
    pushStyle();
    fill(255);
    stroke(150);
    beginShape();
    for (int i = 0; i < points.size(); i++) {
      vertex(points.get(i).pos.x, points.get(i).pos.y, points.get(i).pos.z);
    }
    endShape(PConstants.CLOSE);
    popStyle();
  }

  void addPoint(Point newPoint) {
    points.add(newPoint);
  }
}

