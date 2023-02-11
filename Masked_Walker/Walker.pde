class Walker {
  PVector pos;
  
  Walker(int x, int y){
    pos = new PVector(x, y);
  }
  
  void show(){
    stroke(50, 100);
    fill(0, 100, 255, 25);
    ellipse(pos.x, pos.y, 20, 20);
  }
  
  void update(){
    int newX = int(pos.x + random(-5, 6));
    int newY = int(pos.y + random(-5, 6));
    color c = mask.get(newX, newY);
    if (c != color(0)){
      pos.x = newX;
      pos.y = newY;
    }
  }
}