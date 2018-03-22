// time stretching with processing.sound functions
// BPM taken from sensors, initial calibration with mouse click

import processing.sound.*;
import oscP5.*; 

// sound
final float BPM = 85;
final float MAX_DELTA_MS = 3000;
final float precision=pow(10, -2);

SoundFile soundfile;
int prevMS, currMS;
boolean start=true;
float currRate = 1, currBPM=BPM, prevBPM = 1, prevRate=1; // prev only used for the graphics!
float[] rates = new float[6];
float[] weights = {.1, .125, .25, .5, .325, .25};
float totWeights=0;

// sensors
OscP5 oscP5;
final int IN_PORT_NUMBER = 81;
sensorData gyr;
sensorData orient;
final float ABS_THRESHOLD = 7;
float ab=0, prevAb, maxAbs=0, maxAb=0;
float prevV, prevV2, prevV3;
int triggerIndex=0;
int prevMillis;
boolean positive_orientation = false;
boolean calibrated = false;

// -------------------------------------------------
void setup() {

  // sound
  for (int i=0; i<weights.length; i++)
  {
    rates[i] = 1;
    totWeights += weights[i];
  }

  soundfile = new SoundFile(this, "arcticMonkeys.mp3");
  soundfile.loop();
  
  // graphics
  size(640, 360);
  background(100);
  
  // sensors
  // the plugged method is called if an OSC message with the specified pattern is received
  gyr = new sensorData("gyroscope");
  orient = new sensorData("orientation");
  oscP5 = new OscP5(this,IN_PORT_NUMBER);
  oscP5.plug(this,"gyrX","/gyroscope/X");
  oscP5.plug(this,"gyrY","/gyroscope/Y");
  oscP5.plug(this,"gyrZ","/gyroscope/Z");
  oscP5.plug(this,"orientZ","/orientation/Z");
  
  prevMillis = millis();
}      

void draw() {
      
  if(calibrated)
  {
    // sound
    soundfile.rate(currRate);
    
    // graphics  
    if (frameCount==600)
    {
      frameCount = 1;
      background(100,100,100);
    }
    
    //line(frameCount-1, prevRate*50+100, frameCount, currRate*50+100);
    //prevRate = currRate;
    
    //line(frameCount-1, prevBPM+height/2, frameCount, currBPM+height/2);
    //prevBPM = currBPM;
    
    // sensors
    int tmpMillis = millis();
    prevAb=ab;
    ab = sqrt(pow(gyr.x,2) + pow(gyr.z,2));
    if(ab>prevAb)
    {
      maxAb = ab;
    }
    else
    {
      if(maxAb>ABS_THRESHOLD && tmpMillis-prevMillis>150 && (gyr.z<0 && !positive_orientation || gyr.z>=0 && positive_orientation))  //<slow movements don't trigger> && <one trigger per beat> && <only up->down triggers>
      {
        // sound
        beatDetected();
        // graphics
        triggerIndex++;
        println(triggerIndex + " - triggered! ");// + maxAb + " " + (tmpMillis-prevMillis));
        println("");
        background(255, 102, 0);
        // sensors
        prevMillis = tmpMillis;
        maxAb = 0;
      }
      else{
        background(100,100,100);
      }
    }
    if(ab>maxAbs && ab<1000)
    {
      maxAbs = ab;
    }
  }
}

void mousePressed() {
  //if(mouseButton == LEFT)
  //{
  //  beatDetected();
  //}
  
  if (orient.z>=0)
  {
    positive_orientation = true;
  }
  else
  {
    positive_orientation = false;
  }
  println("Positive z orientation: " + positive_orientation + " " + orient.z);
  calibrated = true;
  
}

void beatDetected() {
  int deltaMS, i;
  prevMS = currMS;
  currMS = millis();
  float currRateTMP;

  deltaMS = currMS - prevMS; 

  if (!start)
  {    
    if (deltaMS <= MAX_DELTA_MS)
    {
      currBPM = round(60/(deltaMS/1000.0));
      currRateTMP = round(currBPM  * 10 / BPM)/10.0;
      for (i=0; i<rates.length-1; i++)
      {
        rates[i] = rates[i+1];
        print(rates[i] + " ");
      }
      println();
      rates[rates.length-1] = currRateTMP;
      for (currRateTMP = 0, i=0; i<rates.length; i++)
      {
        currRateTMP += rates[i] * weights[i];
      }
      currRate = round(currRateTMP/totWeights * 10)/10.0;
      rates[rates.length-1] = currRate;
      println("BPM: " + currBPM + " rate: " + currRate);
    }
  } 
  else
  {
    start = false;
  }
}

void gyrX(float accValue){
  gyr.x = accValue;
}

void gyrY(float accValue){
  gyr.y = accValue;
}

void gyrZ(float accValue){
  gyr.z = accValue;
  //gyr.printData();
}

void orientZ(float accValue){
  orient.z = accValue;
  //gyr.printData();
}