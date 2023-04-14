// this is derived from CT77 Book 3
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
      if (twoDice() <= 9){ gasGiant = true; }  // this is in Book 2, p.35
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

class System_CT81 extends System {
  String travelZone = "Green";
  
  System_CT81(Coordinate _coord){
    super(_coord);
    
    // system occurrence identical to CT77
    // naval base identical to CT77
    // scout base identical to CT77
    // gas giant identical to CT77
    
    // routes are referee fiat in CT81 - keeping the system from CT77 
    
    if (occupied){ 
      uwp = new UWP_CT81();
      trade = new TradeClass_CT81((UWP_CT81)uwp);
      travelZone = generateTravelZone();
    }
    
  }
  System_CT81(JSONObject _json){
    super(_json);
    
    if (occupied){
      uwp        = new UWP_CT81(_json.getJSONObject("UWP"));
      trade      = new TradeClass_CT81((UWP_CT81)uwp);
      travelZone = _json.getString("Travel Zone"); 
    }
  }
  
  // **** need to add travel zone to JSON and string output
  String generateTravelZone(){
    // Travel Zones are referee fiat in CT81
    // it is strongly implied by later sources (Spinward Marches & Solomani Rim)
    // that Starport X indicates a Red zone (see pp. 36 + 40 of Spinward Marches)
    
    // Exceptions to this observation:
    // Andor (C) & Candory (C) - Five Sisters/Spinward Marches - Red Zone
    // Zeta 2 (X) - Vilis/Spinward Marches - Green Zone
    // Djinni (E) - Lanth/Spinward Marches - Red Zone
    // Rimmon (X) - Suleiman/Solomani Rim - Green Zone
    // Weipu (X) - Alderamin/Solomani Rim - Green Zone
    // Khugi (X) - Banasdan/Solomani Rim - Green Zone
    // Kishakhpap (X) - Albadawi/Solomani Rim - Green Zone
    // Altair (X) - Dingir/Solomani Rim - Green Zone
    // Haddad (X) - Capella/Solomani Rim - Green Zone
    // Pollux (X) - Gemini/Solomani Rim - Green Zone    

    // MegaTraveller introduces a table that imposes zones for extreme gov/law combinations

    // I'll incorporate those here, though they're not strictly CT81 RAW
    // A couple other thoughts:
    //  - have a small random chance of Amber zone on any (non-Red) system
    //  - no fuel available seems like an Amber condition to me, add that
    
    if (uwp.starport == 'X'){
      if (twoDice() < 11){
        return "Red";
      }
    }
    
    int dieThrow = twoDice();
    if (dieThrow <= 3){ return "Amber"; }
    if (dieThrow == 12 && !(uwp.starport == 'X')){ return "Red"; }
    if ((uwp.starport == 'X' || uwp.starport == 'E') &&
         uwp.hydro == 0 &&
         gasGiant == false){ return "Amber"; }
    
    return "Green";
  }

  String toString(){
    String description = super.toString();
    String firstHalf = description.substring(0, 36);
    String secondHalf = description.substring(36, description.length());
    
    String zone = "   ";
    if (travelZone.equals("Red")){ zone = " R "; }
    if (travelZone.equals("Amber")){ zone = " A "; }
    
    if (occupied){
      return firstHalf + zone + secondHalf;
    } else {
      return "EMPTY : " + coord.toString();
    }
  }

  JSONObject asJSON(){
    JSONObject json = super.asJSON();
    if (occupied){
      json.setString("Travel Zone", travelZone);
    }
    return json;
  }
}