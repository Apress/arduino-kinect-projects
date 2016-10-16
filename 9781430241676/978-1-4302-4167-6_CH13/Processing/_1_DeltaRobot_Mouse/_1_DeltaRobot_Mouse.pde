import processing.opengl.*;
import kinectOrbit.KinectOrbit;
import SimpleOpenNI.*;
// Initialize Orbit and simple-openni Objects
KinectOrbit myOrbit;
SimpleOpenNI kinect;

// Delta Robot
DeltaRobot dRobot;
PVector motionVec;

public void setup() {

  size(1200, 900, OPENGL);
  smooth();

  // Orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.setCSScale(100);

  // Initialize the Delta Robot to the real dimensions
  dRobot = new DeltaRobot(250, 430, 90, 80);
}

public void draw() {
  background(0);

  myOrbit.pushOrbit(this); // Start Orbiting

  motionVec = new PVector(width/2-mouseX, 0, height/2-mouseY);// Set the relative motion vector
  dRobot.moveTo(motionVec); // Move the robot to the relative motion vector
  dRobot.draw();  // Draw the delta robot in the current view.

  myOrbit.popOrbit(this); // Stop Orbiting
}

