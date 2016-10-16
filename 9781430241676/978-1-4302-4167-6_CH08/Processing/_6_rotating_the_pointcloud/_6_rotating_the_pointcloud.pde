import processing.opengl.*;
import SimpleOpenNI.*;
SimpleOpenNI kinect;

float        zoomF = 0.3f;
float        rotX = radians(180); 
float        rotY = radians(0);

// The float tableRotation will store our rotation angle. This is the value that will need to be assigned a default value for the calibration to be permanent.

float        tableRotation = 0;

// The setup() function will include all the necessary functions to set the sketch size, initialize the Simple-OpenNI object, and set the initial perspective settings.

void setup()
{
  size(1024, 768, OPENGL);  
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(false);	// disable mirror
  kinect.enableDepth();	// enable depthMap generation 
  perspective(95, float(width)/float(height), 10, 150000);
}

//Within the draw() function, we will update the Kinect data, and then we will set the perspective settings using the functions rotateX(), rotateY() and scale().

void draw()
{
  kinect.update();   // update the cam
  background(255);
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

// Then, we will declare and initialize the necessary variables for the drawing of the point cloud, as we have done in other projects.

  int[]   depthMap = kinect.depthMap(); // tip – this line will throw an error if your Kinect is not connected
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

// We will set the rotation center of the scene for visual purposes 1000 in front of the camera, which is close to the distance from the Kinect to the center of the table.

  translate(0, 0, -1000);  
  stroke(0);

  PVector[] realWorldMap = kinect.depthMapRealWorld();
  PVector newPoint = new PVector();

//To make things clearer, let’s mark a point that is in on Kinect’s z-axis (so it’s X and Y are equal to 0). This code is using realWorldMap array, which is an array of 3d coordinates of each screen point, and we’re simply choosing the one that is in the middle of the screen (hence depthWidth/2 and depthHeight/2). As we are in coordinates of Kinect, where (0,0,0) is the sensor itself, we are sampling the depth there, and placing the red cube using the function drawBox(), that we will implement later.

  index = kinect.depthWidth()/2 + kinect.depthHeight()/2 * kinect.depthWidth();
  float pivotDepth = realWorldMap[index].z; 
  fill(255,0,0);
  drawBox(0, 0, pivotDepth, 50);  

  for(int y=0; y < kinect.depthHeight(); y+=steps)
  {
    for(int x=0; x < kinect.depthWidth(); x+=steps)
    {
      index = x + y * kinect.depthWidth();
      if(depthMap[index] > 0)
      { 
        realWorldPoint = realWorldMap[index];
        realWorldPoint.z -= pivotDepth;
        
        float ss = sin(tableRotation);
        float cs = cos(tableRotation);
        
        newPoint.x = realWorldPoint.x;
        newPoint.y = realWorldPoint.y*cs - realWorldPoint.z*ss;
        newPoint.z = realWorldPoint.y*ss + realWorldPoint.z*cs + pivotDepth;
        point(newPoint.x, newPoint.y, newPoint.z);  
      }
    }
  } 

// Now, we will display the value of our tableRotation

  println("tableRot = " + tableRotation);
  kinect.drawCamFrustum();   // draw the kinect cam
}

//Within the KeyPressed() callback function, we will add code that will react to pressing key 1 and 2, changing the values of tableRotation by small increments/decrements. We will also be listening for input from the arrow keys to change the point of view.

void keyPressed()
{
  switch(key)
  {
  case '1':
    tableRotation -= 0.05;
    break;
  case '2':
    tableRotation += 0.05;
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if(keyEvent.isShiftDown())
    {
      zoomF += 0.02f;
    }
    else
    {
      rotX += 0.1f;
    }
    break;
  case DOWN:
    if(keyEvent.isShiftDown())
    {
      zoomF -= 0.02f;
      if(zoomF < 0.01)
        zoomF = 0.01;
    }
    else
    {
      rotX -= 0.1f;
    }
    break;
  }
}

void drawBox(float x, float y, float z, float size)
{
  pushMatrix();
    translate(x, y, z);
    box(size);
  popMatrix();
}
