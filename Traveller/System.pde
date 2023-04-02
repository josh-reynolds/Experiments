class System {
  Polygon hex;
  Coordinate coord;
  Boolean occupied = false;
  UWP uwp;
  Boolean navalBase = false;
  Boolean scoutBase = false;
  Boolean gasGiant = false;
  TradeClass trade;
  String name = "";
  ArrayList<Route> routes;
  
  float yOffset = sqrt((hexRadius * hexRadius) - (hexRadius/2 * hexRadius/2));
  int startX = hexRadius + border;
  int startY = (int)yOffset + border;
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Polygon(getX(coord.column), getY(coord.row, coord.column), hexRadius);
    
    if (random(1) > 0.5){ 
      occupied = true;
      uwp = new UWP();
      navalBase = generateNavalBase();
      scoutBase = generateScoutBase();
      if (twoDice() <= 9){ gasGiant = true; }
      trade = new TradeClass(uwp);
      name = lines[floor(random(lines.length))];
      routes = new ArrayList<Route>();
    }
  } 
  
  System(JSONObject _json){
    coord    = new Coordinate(_json.getJSONObject("Coordinate"));  // might pass this in instead...
    hex      = new Polygon(getX(coord.column), getY(coord.row, coord.column), hexRadius);
    occupied = _json.getBoolean("Occupied");
    
    if (occupied){
      name      = _json.getString("Name");
      navalBase = _json.getBoolean("Naval Base");
      scoutBase = _json.getBoolean("Scout Base");
      gasGiant  = _json.getBoolean("Gas Giant");
      uwp       = new UWP(_json.getJSONObject("UWP"));
      trade     = new TradeClass(uwp);
      routes    = new ArrayList<Route>();
    }
  }
  
  void addRoute(Route _r){
    routes.add(_r);
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

  void showForeground(PGraphics _pg){
    if (occupied){
      _pg.strokeWeight(1);
      
      if (uwp.hydro == 0){ 
        _pg.fill(scheme.cellBackground);
      } else {
        _pg.fill(scheme.waterPresent);
      }
      _pg.stroke(scheme.hexElements);
      _pg.ellipse(hex.x, hex.y, 5 * hexRadius/12, 5 * hexRadius/12);
      
      _pg.fill(scheme.hexElements);
      _pg.textSize(12);
      _pg.textAlign(CENTER, CENTER);
      _pg.text(uwp.starport, hex.x, hex.y - hexRadius/2);
      
      if (navalBase){
        _pg.fill(scheme.hexElements);
        hex.drawStar(_pg, hex.x - 5 * hexRadius/12, hex.y - 5 * hexRadius/12, hexRadius/7);
      }
      
      if (scoutBase){
        _pg.fill(scheme.hexElements);
        hex.drawTriangle(_pg, hex.x - 5 * hexRadius/12, hex.y + hexRadius/3, hexRadius/7);
      }
      
      if (gasGiant){
        _pg.fill(scheme.hexElements);
        _pg.ellipse(hex.x + hexRadius/3, hex.y - hexRadius/3, hexRadius/6, hexRadius/6);
      }
    }
  }  

  void showBackground(PGraphics _pg){
    hex.drawHex(_pg);
    
    _pg.fill(scheme.cellOutline);
    _pg.textSize(9);
    _pg.textAlign(CENTER, TOP);
    _pg.text(coord.toString(), hex.x, hex.y + hexRadius/2);
  }

  void showName(PGraphics _pg){
    _pg.fill(scheme.worldName);
    _pg.textSize(11);
    _pg.textAlign(CENTER, CENTER);
    if (uwp.pop >= 9){
      _pg.text(name.toUpperCase(), hex.x, hex.y + hexRadius/2);
    } else {
      _pg.text(name, hex.x, hex.y + hexRadius/2);
    }
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
    
    if (occupied){
      return outputName + coord.toString() + " : " + uwp.toString() + " " + nb + sb + gg + " " + trade.toString();
    } else {
      return "EMPTY : " + coord.toString();
    }
  }
  
  String listRoutes(){
    String output = "";
    for (Route r : routes){
      output += r.toString();
      output += "\n";
    }
    return output;
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    json.setJSONObject("Coordinate", coord.asJSON());
    json.setBoolean("Occupied", occupied);
    if (occupied){
      json.setString("Name", name);
      json.setBoolean("Naval Base", navalBase);
      json.setBoolean("Scout Base", scoutBase);
      json.setBoolean("Gas Giant", gasGiant);
      json.setJSONObject("UWP", uwp.asJSON());
    }
    return json;
  }
  
  // loop & geometry are 0-based, but coordinates are 1-based
  // so have adjustments in these functions to reconcile
  
  float getX(int _xCoord){
    return startX + (_xCoord - 1) * (hexRadius * 1.5);
  }
  
  float getY(int _yCoord, int _xCoord){
    float columnAdjust;
    if ((_xCoord - 1) % 2 == 0){
      columnAdjust = 0;
    } else {
      columnAdjust = yOffset;
    }
    
    return startY + (yOffset * (_yCoord - 1) * 2) + columnAdjust;
  }
}