class Polygon {
  float x, y;
  float radius;
  
  Polygon(float _x, float _y, float _radius){
    x = _x;
    y = _y;
    radius = _radius;
  }

  // hex.drawHex(_pg);
  void drawHex(PGraphics _pg){
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

  // hex.drawStar(_pg, hex.x - 5 * hexRadius/12, hex.y - 5 * hexRadius/12, hexRadius/7);
  void drawStar(PGraphics _pg, float _x, float _y, float _radius){
    _pg.pushMatrix();
      _pg.translate(_x, _y);
      _pg.rotate(-PI/2);
    
      float vX, vY, angle;
      int sides = 5;
      
      _pg.beginShape();
      for (int i = 0; i < sides * 2; i += 2){
        angle = TWO_PI / sides * i;
        vX = _radius * cos(angle);
        vY = _radius * sin(angle);
        
        _pg.vertex(vX,vY);
      }
      _pg.endShape(CLOSE);
    _pg.popMatrix();
  }

  // hex.drawTriangle(_pg, hex.x - 5 * hexRadius/12, hex.y + hexRadius/3, hexRadius/7);
  void drawTriangle(PGraphics _pg, float _x, float _y, float _radius){
    _pg.pushMatrix();
      _pg.translate(_x, _y);
      _pg.rotate(-PI/2);
    
      float vX, vY, angle;
      int sides = 3;
      
      _pg.beginShape();
      for (int i = 0; i < sides; i++){
        angle = TWO_PI / sides * i;
        vX = _radius * cos(angle);
        vY = _radius * sin(angle);
        
        _pg.vertex(vX,vY);
      }
      _pg.endShape(CLOSE);
    _pg.popMatrix();
  }
}