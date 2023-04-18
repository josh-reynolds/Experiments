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
    
  System(Coordinate _coord){
    coord = _coord;
    hex = new Polygon(coord.getScreenX(), coord.getScreenY(), hexRadius);
    
    if (random(1) > 0.5){ 
      occupied = true;
      uwp = generateUWP();
      navalBase = generateNavalBase();
      scoutBase = generateScoutBase();
      if (twoDice() <= 9){ gasGiant = true; }  // this is in Book 2, p.35
      trade = generateTradeClass(uwp);
      name = lines[floor(random(lines.length))];
      routes = new ArrayList<Route>();
    }
  } 
  
  System(JSONObject _json){
    coord    = new Coordinate(_json.getJSONObject("Coordinate"));  // might pass this in instead...
    hex = new Polygon(coord.getScreenX(), coord.getScreenY(), hexRadius);
    occupied = _json.getBoolean("Occupied");
    
    if (occupied){
      name      = _json.getString("Name");
      navalBase = _json.getBoolean("Naval Base");
      scoutBase = _json.getBoolean("Scout Base");
      gasGiant  = _json.getBoolean("Gas Giant");
      uwp       = generateUWP(_json.getJSONObject("UWP"));
      trade     = generateTradeClass(uwp);
      routes    = new ArrayList<Route>();
    }
  }
  
  TradeClass generateTradeClass(UWP _uwp){
    return new TradeClass(_uwp);
  }
  
  UWP generateUWP(){
    return new UWP();
  }

  UWP generateUWP(JSONObject _json){
    return new UWP(_json);
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
      travelZone = generateTravelZone();
    }
  }
  
  System_CT81(JSONObject _json){
    super(_json);
    
    if (occupied){
      travelZone = _json.getString("Travel Zone"); 
    }
  }
  
  TradeClass generateTradeClass(UWP _uwp){
    return new TradeClass_CT81((UWP_CT81)_uwp);
  }
  
  UWP generateUWP(){
    return new UWP_CT81();
  }
  
  UWP generateUWP(JSONObject _json){
    return new UWP_CT81(_json);
  }
  
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

class System_ScoutsEx extends System_CT81 {
  // Extension of CT81 rules - elements mostly the same, plus:
  //  - Stars & orbits
  //  - Influence of previous on UWP characteristics
  //  - Additional worlds (non-mainworld)
  //  - Satellites
  //
  // Scouts also introduces subsector density (handle separately)
  //  
  // Some considerations:
  //  - Data format - JSON as-is will get very verbose
  //  - How to mark mainworld
  //  - Extended/derived characteristics (save for later)
 
  Star[] stars;   // stars[0] is Primary
  //Orbit[] orbits;
  String[] orbits; // still working through the class hierarchy, let's do strings for now
  
  System_ScoutsEx(Coordinate _coord){
    super(_coord);
    
    if (occupied){
      stars = new Star[getStarCount()];
      for (int i = 0; i < stars.length; i++){
        if (i == 0){
          stars[i] = new Star(true, this);
        } else {
          stars[i] = new Star(false, this);
        }
      }
      
      println("Primary: " + stars[0]);

      int maxCompanion = 0;
      for (int i = 1; i < stars.length; i++){
        int modifier = 4 * (i - 1);
        println("Assessing companion star: " + stars[i] + " modifier: +" + modifier);
        int dieThrow = twoDice() + modifier;
        int result = 0;
        if (dieThrow < 4  ){ result = 0; }  // actually "Close" - not the same as Orbit 0, how to represent?
        if (dieThrow == 4 ){ result = 1; }
        if (dieThrow == 5 ){ result = 2; }
        if (dieThrow == 6 ){ result = 3; }
        if (dieThrow == 7 ){ result = 4 + oneDie(); }
        if (dieThrow == 8 ){ result = 5 + oneDie(); }
        if (dieThrow == 9 ){ result = 6 + oneDie(); }
        if (dieThrow == 10){ result = 7 + oneDie(); }
        if (dieThrow == 11){ result = 8 + oneDie(); }
        if (dieThrow >= 12){               // "Far" - should convert this to an orbit number 
          int distance = 1000 * oneDie();
          if (distance == 1000                    ){ result = 14; }
          if (distance == 2000                    ){ result = 15; }
          if (distance == 3000 || distance == 4000){ result = 16; }
          if (distance >= 5000                    ){ result = 17; } // from tables on Scouts p.46 - should derive the formula instead
                                                                    // or calculate "Far" in terms of orbit number to begin with
        }
        if (result > maxCompanion){ maxCompanion = result; }
        println(result);
        // need to classify Close & Far
        // need to screen orbits inside Primary
        // need to check for companions on Far results
        // need to handle case where companion orbit is greater than max orbits
      }

      int orbitCount = calculateMaxOrbits();
      //orbits = new Orbit[orbitCount];
      if (orbitCount < maxCompanion){
        orbits = new String[maxCompanion];
        // need to ensure orbits inbetween are empty 
      } else {
        orbits = new String[orbitCount];
      }
      if (stars.length == 1){
        println("Orbits: " + orbits.length);
      } else {
        println("Orbits: " + orbits.length + " EMPTY: " + (maxCompanion - orbitCount));
      }
    } else {
      stars = null;
    }
  }

  System_ScoutsEx(JSONObject _json){
    super(_json);
    
    if (occupied){
      JSONArray starList = _json.getJSONArray("Stars");
      stars = new Star[starList.size()];
      for (int i = 0; i < starList.size(); i++){
        stars[i] = new Star(this, starList.getString(i));
      }
    } else {
      stars = null;
    }
  }
  
  String toString(){
    String description = super.toString();
    if (occupied){
      for (Star s : stars){
        description += s.toString() + " ";
      }
    }
    return description;
  }
  
  JSONObject asJSON(){
    JSONObject json = super.asJSON();
    if (occupied){
      JSONArray starList = new JSONArray();
      for (int i = 0; i < stars.length; i++){
        starList.setString(i, stars[i].toString());
      }
      json.setJSONArray("Stars", starList);
    }
    return json;
  }
  
  int getStarCount(){
    int dieThrow = twoDice();
    if (dieThrow < 8){ return 1; }
    if (dieThrow > 7 && dieThrow < 12){ return 2; }
    if (dieThrow == 12){ return 3; }
    return 0;
  }
  
  int calculateMaxOrbits(){
    int modifier = 0;
    if (stars[0].size.equals("II") ){ modifier += 8; }  // rules include Ia/Ib supergiants here, but no means to generate them - omitting
    if (stars[0].size.equals("III")){ modifier += 4; }
    if (stars[0].type == 'M'       ){ modifier -= 4; }
    if (stars[0].type == 'K'       ){ modifier -= 2; }

    int result = twoDice() + modifier; 
    if (result < 1){ 
      return 0; 
    } else {
      return result;
    }
  }
}