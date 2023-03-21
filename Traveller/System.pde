class System {
  Hex hex;
  Coordinate coord;
  Boolean occupied = false;
  UWP uwp;
  Boolean navalBase = false;
  Boolean scoutBase = false;
  Boolean gasGiant = false;
  TradeClass trade;
  String name = "";
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Hex(getX(coord.column), getY(coord.row, coord.column), hexRadius);
    
    if (random(1) > 0.5){ 
      occupied = true;
      uwp = new UWP();
      navalBase = generateNavalBase();
      scoutBase = generateScoutBase();
      if (twoDice() <= 9){ gasGiant = true; }
      trade = new TradeClass(uwp);
      name = lines[floor(random(lines.length))];
    }
  } 
    
  int distanceToSystem(System _s){    
    return coord.distanceTo(_s.coord);
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
  
  void showForeground(){
    if (occupied){
      strokeWeight(1);
      
      if (uwp.hydro == 0){ 
        fill(scheme.cellBackground);
      } else {
        fill(scheme.waterPresent);
      }
      stroke(scheme.hexElements);
      ellipse(hex.x, hex.y, 5 * hexRadius/12, 5 * hexRadius/12);
      
      fill(scheme.hexElements);
      textSize(12);
      textAlign(CENTER, CENTER);
      text(uwp.starport, hex.x, hex.y - hexRadius/2);
      
      if (navalBase){
        fill(scheme.hexElements);
        drawStar(hex.x - 5 * hexRadius/12, hex.y - 5 * hexRadius/12, hexRadius/7);
      }
      
      if (scoutBase){
        fill(scheme.hexElements);
        drawTriangle(hex.x - 5 * hexRadius/12, hex.y + hexRadius/3, hexRadius/7);
      }
      
      if (gasGiant){
        fill(scheme.hexElements);
        ellipse(hex.x + hexRadius/3, hex.y - hexRadius/3, hexRadius/6, hexRadius/6);
      }
    }
  }
  
  void showBackground(){
    hex.show();
    
    fill(scheme.cellOutline);
    textSize(9);
    textAlign(CENTER, TOP);
    text(coord.toString(), hex.x, hex.y + hexRadius/2);
  }
  
  void showName(){
    fill(scheme.worldName);
    textSize(11);
    textAlign(CENTER, CENTER);
    if (uwp.pop >= 9){
      text(name.toUpperCase(), hex.x, hex.y + hexRadius/2);
    } else {
      text(name, hex.x, hex.y + hexRadius/2);
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
    
    String outputName = name;
    if (name.length() >= 15){ outputName = name.substring(0,15); }
    int paddingLength = (16 - outputName.length());
    for (int i = 1; i <= paddingLength; i++){
      outputName += " ";
    }
       
    return outputName + coord.toString() + " : " + uwp.toString() + " " + nb + sb + gg + " " + trade.toString();
  }
}