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
float currRate = 1, currBPM=BPM;
float[] rates = new float[6];
float[] weights = {.1, .125, .25, .5, .25, .125};
float totWeights=0;

// sensors
final int IN_PORT_NUMBER = 81;
final float ABS_THRESHOLD = 7;
final float CRAZY_RATE = 3;
OscP5 oscP5;
sensorData gyr;
sensorData orient;
float ab=0, prevAb, maxAbs=0, maxAb=0;
float[] prevRate = {1, 1};
int triggerIndex=0;
int prevMillis;
boolean positiveOrientation = false;
boolean sensorsCalibrated = false, sensorsConnected = false;

void setup() {
  
  // sound
  for (int i=0; i<weights.length; i++)
  {
    rates[i] = 1;
    totWeights += weights[i];
  }

  soundfile = new SoundFile(this, "arcticMonkeys.mp3");
  
  // graphics
  size(640, 360);
  //fullScreen();
  background(0);
  
  // sensors
  // the plugged method is called if an OSC message with the specified pattern is received
  gyr = new sensorData("gyroscope");
  orient = new sensorData("orientation");
  oscP5 = new OscP5(this,IN_PORT_NUMBER);
  oscP5.plug(this,"gyrX","/gyroscope/X");
  oscP5.plug(this,"gyrZ","/gyroscope/Z");
  oscP5.plug(this,"orientZ","/orientation/Z");
  
  prevMillis = millis();
}      

void draw() {
      
  if(sensorsCalibrated)
  {
    
    // sound
    soundfile.rate(currRate);
    
    // graphics
    background(0);

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
      if(maxAb>ABS_THRESHOLD && tmpMillis-prevMillis>150 && (gyr.z<0 && !positiveOrientation || gyr.z>=0 && positiveOrientation))  //<slow movements don't trigger> && <one trigger per beat> && <only up->down triggers>
      {
        // sound
        beatDetected();
        // graphics
        triggerIndex++;
        println(triggerIndex + " - triggered! " + maxAb + " " + gyr.z);
        println("");
        background(255, 102, 0);
        // sensors
        prevMillis = tmpMillis;
        maxAb = 0;
      }
      else{
        background(0);
      }
    }
    if(ab>maxAbs && ab<1000)
    {
      maxAbs = ab;
    }
  }
  else
  {  
    if(orient.z==sensorData.RESET || gyr.x==sensorData.RESET || gyr.z==sensorData.RESET)
    {
      background(255,0,0);
      //println("orient.z: " + orient.z + " gyr.y: " + gyr.y + " gyr.z: " + gyr.z);
      String s = "SENSORS NOT CONNECTED";
      textSize(round(height/10));
      fill(255);
      textAlign(CENTER, CENTER);
      text(s, width/2, height/2);
    }
    else
    {
      background(0);
      String s = "PRESS TO START";
      textSize(round(height/5));
      fill(255);
      textAlign(CENTER, CENTER);
      text(s, width/2, height/2);
      sensorsConnected = true;
    }

  }
}

void mousePressed() {
  if(sensorsConnected)
  {
    if (orient.z>=0)
    {
      positiveOrientation = true;
    }
    else
    {
      positiveOrientation = false;
    }
    println("Positive z orientation: " + positiveOrientation + " " + orient.z);
    sensorsCalibrated = true;
    soundfile.loop();
  }
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
      currRateTMP = round(currBPM  * 10 / BPM)/10.0; // keep only 1 decimal
      println(currRateTMP);
      for (i=0; i<rates.length-1; i++)
      {
        print(rates[i] + " ");
        rates[i] = rates[i+1];
      }
      println(rates[i]);
      if(currRateTMP<CRAZY_RATE)
      {
        rates[rates.length-1] = currRateTMP;
      }
      for (currRateTMP = 0, i=0; i<rates.length; i++)
      {
        print(rates[i] + " ");
        currRateTMP += rates[i] * weights[i];
      }
      println();
      currRate = round(currRateTMP/totWeights * 10)/10.0;
      // if it is the third change in three beats keep the previous rate
      if(prevRate[0] != prevRate[1])
      {  
        currRate = prevRate[1];
      }
      else
      {
        // round to even decimals (.0 .2 .4 .6 .8)
        println("before rounding: " + currRate);
        if(currRate>1)
        {
          currRate = (int(currRate * 10) + int(currRate*10)%2)/10.0;
        }
        else
        {
          currRate = (int(currRate * 10) - int(currRate*10)%2)/10.0;
        }
      }
      prevRate[0] = prevRate[1];
      prevRate[1] = currRate;
      //rates[rates.length-1] = currRate; // NO! 
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

void gyrZ(float accValue){
  gyr.z = accValue;
  //gyr.printData();
}

void orientZ(float accValue){
  orient.z = accValue;
  //gyr.printData();
}