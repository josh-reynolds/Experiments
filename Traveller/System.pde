class System {
  Hex hex;
  Coordinate coord;
  Boolean occupied = false;
  UWP uwp;
  Boolean navalBase = false;
  Boolean gasGiant = false;
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Hex(getX(coord.column), getY(coord.row, coord.column), hexRadius, color(0));
    
    if (random(1) > 0.5){ 
      occupied = true;
      uwp = new UWP();
      navalBase = generateNavalBase();
      if (twoDice() <= 9){ gasGiant = true; }
    }
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
      
      if (gasGiant){
        fill(255);
        ellipse(hex.x + hexRadius/3, hex.y - hexRadius/3, hexRadius/6, hexRadius/6);
      }
    }
  }
  
  String toString(){
    String nb = " ";
    if (navalBase){ nb = "N"; }
    
    String gg = "";
    if (gasGiant){ gg = "G"; }
    
    return coord.toString() + " : " + uwp.toString() + " " + nb + "   " + gg;
  }
}