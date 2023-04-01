class Hex {
  float x, y;
  float radius;
  
  Hex(float _x, float _y, float _radius){
    x = _x;
    y = _y;
    radius = _radius;
  }

  void show(){
    pushMatrix();
      translate(x,y);
      stroke(scheme.cellOutline);
      strokeWeight(1);
      fill(scheme.cellBackground);
    
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

  void show(PGraphics _pg){
    _pg.pushMatrix();
      _pg.translate(x,y);
      _pg.stroke(scheme.cellOutline);
      _pg.strokeWeight(1);
      _pg.fill(scheme.cellBackground);
    
      float vX, vY, angle;
      int sides = 6;
      
      _pg.beginShape();
      for (int i = 0; i < sides; i++){
        angle = TWO_PI / sides * i;
        vX = radius * cos(angle);
        vY = radius * sin(angle);
        
        _pg.vertex(vX,vY);
      }
      _pg.endShape(CLOSE);
    _pg.popMatrix();
  }
}