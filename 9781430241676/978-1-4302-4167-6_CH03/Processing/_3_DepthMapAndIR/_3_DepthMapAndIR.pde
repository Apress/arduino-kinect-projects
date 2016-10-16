import SimpleOpenNI.*;

SimpleOpenNI kinect;

void setup() {

  kinect = new SimpleOpenNI(this);

  // enable mirror
  kinect.setMirror(true);

  // enable depthMap and IR image
  kinect.enableDepth();
  kinect.enableIR();

  size(kinect.depthWidth()+kinect.irWidth(), kinect.depthHeight());

}

void draw() {

  kinect.update();

  // draw depthImageMap and IR images
  image(kinect.depthImage(), 0, 0);
  image(kinect.irImage(),kinect.depthWidth(),0);

}

