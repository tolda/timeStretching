import oscP5.*;
  
OscP5 oscP5;
final int IN_PORT_NUMBER = 81;
sensorData acc;
sensorData gyr;
sensorData orient;

final float ABS_THRESHOLD = 7;
float ab=0, prevAb, maxAb=0;
float prevV, prevV2, prevV3; // plot indexes
int triggerIndex=0; // for debug only
int prevMillis;

void setup() {
  
  size(1200,600);
  background(100,100,100);
  acc = new sensorData("acc");
  gyr = new sensorData("gyr");
  orient = new sensorData("orientation");
  
  
  
  // the plugged method is called if an OSC message with the specified pattern is received
  //oscP5.plug(this,"accX","/accelerometer/X");
  //oscP5.plug(this,"accY","/accelerometer/Y");
  //oscP5.plug(this,"accZ","/accelerometer/Z");
  boolean marta=true;
  if(marta){
    oscP5 = new OscP5(this,IN_PORT_NUMBER);
    oscP5.plug(this,"gyrX","/gyroscope/X");
    oscP5.plug(this,"gyrY","/gyroscope/Y");
    oscP5.plug(this,"gyrZ","/gyroscope/Z");
    
    oscP5.plug(this,"orX","/orientation/X");
    oscP5.plug(this,"orY","/orientation/Y");
    oscP5.plug(this,"orZ","/orientation/Z");
  }
  else{
    oscP5 = new OscP5(this,55000);
    oscP5.plug(this,"michele","/mobile1/gyro");
  }
  prevMillis = millis();
}


void draw() {
  int tmpMillis = millis();
  prevAb = ab;
  ab = sqrt(pow(gyr.x,2) + pow(gyr.z,2));
  if(ab>prevAb)
  {
    maxAb = ab;
  }
  else
  {
    if(maxAb>ABS_THRESHOLD && tmpMillis-prevMillis>150 && gyr.z<0) //<small/slow movements don't trigger> && <one trigger per beat> && <only up->down triggers>
    {
      //println(gyr.z);
      triggerIndex++;
      //println(triggerIndex + " - triggered! " + maxAb + " " +  (tmpMillis-prevMillis));
      //println("");
      //background(255, 102, 0);
      //rect(0,0,40,40);
      prevMillis = tmpMillis;
      maxAb = 0;
    }
    else{
      //background(100,100,100);
      //rect(0,0,40,40);
    }
  }

  if (frameCount==width)
  {
    //stop();
    frameCount = 1;
    background(100,100,100);
  }
  
  //// top plot
  //line(frameCount-1, 200, frameCount, 200);
  //line(frameCount-1, prevV, frameCount, 200-orient.x);
  //prevV = 200-orient.x;
  
  // middle plot
  line(frameCount-1, 300, frameCount, 300);
  line(frameCount-1, prevV2, frameCount, 300-orient.z);
  prevV2 = 300-orient.z;
  
  // bottom plot
  line(frameCount-1, 500, frameCount, 500);
  line(frameCount-1, prevV3, frameCount, 500-gyr.z);
  prevV3 = 500-gyr.z;
}

void mousePressed() {

}

void accX(float oscValue){
  acc.x = oscValue;
}

void accY(float oscValue){
  acc.y = oscValue;
}

void accZ(float oscValue){
  acc.z = oscValue;
  //acc.printData();
}

void gyrX(float oscValue){
  gyr.x = oscValue;
}

void gyrY(float oscValue){
  gyr.y = oscValue;
}

void gyrZ(float oscValue){
  gyr.z = oscValue;
  //gyr.printData();
}

void orX(float oscValue){
  orient.x = oscValue;
}

void orY(float oscValue){
  orient.y = oscValue;
}

void orZ(float oscValue){
  orient.z = oscValue;
  //orient.printData();
}

void michele(float[] sensorValues){
  //println(sensorValues[2]);
  gyr.z=sensorValues[2];
}

 //incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {
  //print("### received an osc message.");
  //println(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag());

  //gyr.x = theOscMessage.get(0).floatValue();
  //gyr.y = theOscMessage.get(0).floatValue();
  //gyr.z = theOscMessage.get(0).floatValue();
  //orient.z = theOscMessage.get(0).floatValue();

}