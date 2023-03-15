class System {
  Hex hex;
  Coordinate coord;
  Boolean occupied = false;
  UWP uwp;
  Boolean gasGiant = false;
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Hex(getX(coord.column), getY(coord.row, coord.column), hexRadius, color(0));
    
    if (random(1) > 0.5){ 
      occupied = true;
      uwp = new UWP();
      if (twoDice() <= 9){ gasGiant = true; }
    }
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
      ellipse(hex.x, hex.y, hexRadius / 3, hexRadius / 3);

      fill(255);
      textSize(12);
      textAlign(CENTER, CENTER);
      text(uwp.starport, hex.x, hex.y - hexRadius / 2);
    }
  }
  
  String toString(){
    String gg = "";
    if (gasGiant){ gg = "G"; }
    
    return coord.toString() + " : " + uwp.toString() + " " + gg;
  }
}