class System {
  Hex hex;
  Coordinate coord;
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Hex(getX(coord.column), getY(coord.row, coord.column), hexRadius, color(0));
  }
  
  void show(){
    hex.show();

    fill(255);
    textSize(10);
    textAlign(CENTER, TOP);
    text(coord.toString(), hex.x, hex.y + hexRadius/2);
  }
  
}