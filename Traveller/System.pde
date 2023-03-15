class System {
  Hex hex;
  Coordinate coord;
  Boolean occupied = false;
  UWP uwp;
  Boolean navalBase = false;
  Boolean scoutBase = false;
  Boolean gasGiant = false;
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Hex(getX(coord.column), getY(coord.row, coord.column), hexRadius, color(0));
    
    if (random(1) > 0.5){ 
      occupied = true;
      uwp = new UWP();
      navalBase = generateNavalBase();
      scoutBase = generateScoutBase();
      if (twoDice() <= 9){ gasGiant = true; }
    }
  }
  
  Boolean generateScoutBase(){
    int modifier = 0;
    if (uwp.starport == 'A'){ modifier = -3; }
    if (uwp.starport == 'B'){ modifier = -2; }
    if (uwp.starport == 'C'){ modifier = -1; }
    if (uwp.starport == 'E' || uwp.starport == 'X'){ return false; }
    if (twoDice() + modifier >= 7){ return true; }
    return false;
  }
  
  Boolean generateNavalBase(){
    if (uwp.starport == 'A' || uwp.starport == 'B'){ 
      if (twoDice() >= 8){ return true; }
    }
    return false;
  }
  
  void show(){
    hex.show();

    fill(255);
    textSize(9);
    textAlign(CENTER, TOP);
    text(coord.toString(), hex.x, hex.y + hexRadius/2);
    
    if (occupied){
      if (uwp.hydro == 0){ 
        noFill();
      } else {
        fill(0, 125, 255);
      }
      stroke(255);
      ellipse(hex.x, hex.y, 5 * hexRadius/12, 5 * hexRadius/12);
      
      fill(255);
      textSize(12);
      textAlign(CENTER, CENTER);
      text(uwp.starport, hex.x, hex.y - hexRadius/2);
      
      if (navalBase){
        fill(255);
        drawStar(hex.x - 5 * hexRadius/12, hex.y - 5 * hexRadius/12, hexRadius/7);
      }
      
      if (scoutBase){
        fill(255);
        drawTriangle(hex.x - 5 * hexRadius/12, hex.y + hexRadius/3, hexRadius/7);
      }
      
      if (gasGiant){
        fill(255);
        ellipse(hex.x + hexRadius/3, hex.y - hexRadius/3, hexRadius/6, hexRadius/6);
      }
    }
  }
  
  void drawStar(float _x, float _y, float _radius){
    pushMatrix();
      translate(_x, _y);
      rotate(-PI/2);
    
      float vX, vY, angle;
      int sides = 5;
      
      beginShape();
      for (int i = 0; i < sides * 2; i += 2){
        angle = TWO_PI / sides * i;
        vX = _radius * cos(angle);
        vY = _radius * sin(angle);
        
        vertex(vX,vY);
      }
      endShape(CLOSE);
    popMatrix();
  }
  
  void drawTriangle(float _x, float _y, float _radius){
    pushMatrix();
      translate(_x, _y);
      rotate(-PI/2);
    
      float vX, vY, angle;
      int sides = 3;
      
      beginShape();
      for (int i = 0; i < sides; i++){
        angle = TWO_PI / sides * i;
        vX = _radius * cos(angle);
        vY = _radius * sin(angle);
        
        vertex(vX,vY);
      }
      endShape(CLOSE);
    popMatrix();
  }
  
  String toString(){
    String nb = " ";
    if (navalBase){ nb = "N"; }
    
    String sb = " ";
    if (scoutBase){ sb = "S"; }
    
    String gg = " ";
    if (gasGiant){ gg = "G"; }
    
    return coord.toString() + " : " + uwp.toString() + " " + nb + sb + "   " + gg;
  }
}