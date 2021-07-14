import themidibus.*;
import poseestimator.PoseEstimator;
import processing.video.*;
import themidibus.*;
import controlP5.*;
import java.util.List;
import java.util.Map;
import java.util.Set;

boolean doNotLoadPose = false; //Used to switch off the pose estimation while debugging.
boolean useDefaultRenderer = true; //For experimenting with the P2D renderer.
boolean showFPS = true;
boolean drawControls = true;

PoseEstimator pose;
boolean poseStarted = false; 
Midi midi;

int screenWidth = 640;
int screenHeight = 480;

int totalTime = 0;
int framesElapsed = 0;
int millisecondsElapsed = 0;

final String[] keypointNames = {
    "Nose",// = 0
    "Neck",// = 1
    "Right Shoulder",// = 2
    "Right Elbow",// = 3
    "Right Wrist",// = 4
    "Left Shoulder",// = 5
    "Left Elbow",// = 6
    "Left Wrist",// = 7
    "Right Hip",// = 8
    "Right Knee",// = 9
    "Right Ankle",// = 10
    "Left Hip",// = 11
    "Left Knee",// = 12
    "Left Ankle",// = 13
    "Right Eye",// = 14
    "Left Eye",// = 15
    "Right Ear",// = 16
    "Left Ear"// = 17
}; 

ArrayList<Zone> zones = new ArrayList<Zone>();

//Mouse control variables
Zone selected;
boolean dragging = false;
PVector dragMouseToZone;
enum DragMode {MOVING, RESIZING};
DragMode dragMode = DragMode.MOVING;
PApplet app = this;

InputSource inputSource;
boolean mirrorSource = true;
boolean showImage = true;
boolean showHeatMap = true;
float confidenceThreshold = 0.5;

ControlWindow controls;


void settings()
{
  if (useDefaultRenderer)
  {
    size(screenWidth, screenHeight);
  }
  else
  {
    size(screenWidth, screenHeight, P2D);
  }
}

void setup() 
{ 
  ellipseMode(CORNER);
  fill(255,0,0);
  noStroke();
  
  initialiseChords();

  pose = new PoseEstimator(this);
  if (!doNotLoadPose) pose.start();
  
  Zone z = new StringZone();
  zones.add(z);
  
  midi = new Midi(this);
  initialiseInputSources();
  controls = new ControlWindow(this); 
}

void draw() 
{
  int time = millis();
  
  doRequests();
  
  PImage pic = inputSource.get();
    
  if (pose.isReady())
  {
    if (!poseStarted)
    {
      poseStarted = true;
      controls.refreshGUIFull();
    }
    
    if (inputSource.isReady())
    {
      pose.estimate(pic,mirrorSource);
      
      for(Zone b: zones)
      {
        b.interact(pose);
      }
    }
  }
  
  if (mirrorSource)
  {
    translate(screenWidth/2.0,0); //Flip the image so that it is drawn mirrored
    scale(-1,1);
    translate(-screenWidth/2.0,0);
  }
  
  if (showImage)
  {
    inputSource.draw();
  }
  else
  {
    background(0);
  }
  resetMatrix();

  for(Zone b: zones)
  {
    b.draw();
  }  
  
  time = millis() - time;
  millisecondsElapsed = time;
  totalTime += time;
  framesElapsed++;
  
  if (showFPS)
  {
    fill(255,0,255);
    textSize(12);
    textAlign(LEFT, TOP);
    text("fps: " + (1000.0 / time),5,5);
  }
}

void shutDown()
{
  if (framesElapsed > 0)
  {
    float avgFPS = 1000.0 / (totalTime / (float)framesElapsed);
    println("Average FPS: " + avgFPS);
  }
  exit();
}
