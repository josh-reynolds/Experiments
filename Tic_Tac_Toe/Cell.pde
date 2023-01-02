class Cell{
  int x, y;
  int value = 0;
  
  Cell(int _x, int _y){
    x = _x;
    y = _y;
  }
  
  void show(){
    float topLeftX = x * h;
    float topLeftY = y * v;

    fill(125 + 125 * value);
    rect(topLeftX, topLeftY, h, v);
  }
  
  void update(int increment){
    value += increment;
    if (value > 1) { value = 1; }
    if (value < -1){ value = -1; }    
  }
}