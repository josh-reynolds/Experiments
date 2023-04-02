class Polygon {
  float x, y;
  float radius;
  
  Polygon(float _x, float _y, float _radius){
    x = _x;
    y = _y;
    radius = _radius;
  }

  void drawPolygon(PGraphics _pg, float _radius, int _sides, int _skip){
    // _skip == 1 for a normal convex polygon
    // _skip == 2 for a 'star' concave polygon
    float vX, vY, angle;
    
    _pg.beginShape();
    for (int i = 0; i < _sides * _skip; i += _skip){
      angle = TWO_PI / _sides * i;
      vX = _radius * cos(angle);
      vY = _radius * sin(angle);
      
      _pg.vertex(vX,vY);
    }
    _pg.endShape(CLOSE);
  }

  void drawHex(PGraphics _pg){
    _pg.pushMatrix();
      _pg.translate(x,y);
      _pg.stroke(scheme.cellOutline);
      _pg.strokeWeight(1);
      _pg.fill(scheme.cellBackground);
        
      drawPolygon(_pg, radius, 6, 1);

    _pg.popMatrix();
  }

  void drawStar(PGraphics _pg){
    _pg.pushMatrix();
      _pg.translate(x - 5 * radius/12, y - 5 * radius/12);
      _pg.rotate(-PI/2);
    
      drawPolygon(_pg, radius/7, 5, 2);

    _pg.popMatrix();
  }

  void drawTriangle(PGraphics _pg){
    _pg.pushMatrix();
      _pg.translate(x - 5 * radius/12, y + radius/3);
      _pg.rotate(-PI/2);
    
      drawPolygon(_pg, radius/7, 3, 1);
      
    _pg.popMatrix();
  }
}