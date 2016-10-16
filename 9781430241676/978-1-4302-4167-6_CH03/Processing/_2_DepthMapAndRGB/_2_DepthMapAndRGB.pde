// Import simple-openni
import SimpleOpenNI.*;

// Declare the simple-openni object
SimpleOpenNI kinect;

void setup() {
  
  kinect = new SimpleOpenNI(this);
  
  // enable depthMap and RGB image
  kinect.enableDepth();
  kinect.enableRGB();
  
  // enable mirror
  kinect.setMirror(true);
  
  // Set the size of the sketch to fit the depth map and RGB images
  size(kinect.depthWidth()+kinect.rgbWidth(), kinect.depthHeight());
}

void draw() {
  
  // Update the data from Kinect
  kinect.update();
  
  // draw depthImageMap and RGB images
  image(kinect.depthImage(), 0, 0);
  image(kinect.rgbImage(), kinect.depthWidth(), 0);
}

