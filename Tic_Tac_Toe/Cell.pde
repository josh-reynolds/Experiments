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

    fill(125);
    rect(topLeftX, topLeftY, h, v);
    
    if (value == 1){
      stroke(0);
      strokeWeight(12);
      line(topLeftX + h/3,     topLeftY + v/3, topLeftX + 2 * h/3, topLeftY + 2 * v/3);
      line(topLeftX + 2 * h/3, topLeftY + v/3, topLeftX + h/3,     topLeftY + 2 * v/3);
    }
    if (value == -1){
      stroke(0);
      strokeWeight(12);
      ellipseMode(CORNER);
      ellipse(topLeftX + h/3, topLeftY + v/3, h/3, v/3);
    }
  }
  
  void update(int increment){
    value += increment;
    if (value > 1) { value = 1; }
    if (value < -1){ value = -1; }    
  }
}