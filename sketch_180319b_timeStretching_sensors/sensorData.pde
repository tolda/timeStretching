class sensorData{
  
  final float RESET = 10000;
  float x;
  float y;
  float z;
  String name;
  
  sensorData()
  {
      this.name = "";
      this.x = RESET;
      this.y = RESET;
      this.z = RESET;
  }
  
  sensorData(String name)
  {
      this.name = name;
      this.x = RESET;
      this.y = RESET;
      this.z = RESET;
  }
  
  void printData()
  {
    println(this.name + " X: " + this.x + " Y: " + this.y + " Z: " + this.z);
  }
}