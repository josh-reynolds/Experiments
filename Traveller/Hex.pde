class Hex {
  float x, y;
  float radius;
  color c;
  
  Hex(float _x, float _y, float _radius, color _c){
    x = _x;
    y = _y;
    radius = _radius;
    c = _c;
  }

  void show(){
    pushMatrix();
      translate(x,y);
      stroke(255);
      fill(c);
    
      float vX, vY, angle;
      int sides = 6;
      
      beginShape();
      for (int i = 0; i < sides; i++){
        angle = TWO_PI / sides * i;
        vX = radius * cos(angle);
        vY = radius * sin(angle);
        
        vertex(vX,vY);
      }
      endShape(CLOSE);
    popMatrix();
  } 
}