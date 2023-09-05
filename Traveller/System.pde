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
  Dice roll;
    
    
  System(Coordinate _coord, float _density){
    coord = _coord;
    hex = new Polygon(coord.getScreenX(), coord.getScreenY(), hexRadius);
    roll = new Dice();
    
    if (random(1) < _density){  // TO_DO: may want to rethink this living in System - move up a level?
      occupied = true;
      UWPBuilder ub = ruleset.newUWPBuilder();
      ub.newUWPFor(this);
      navalBase = generateNavalBase();
      scoutBase = generateScoutBase();
      if (roll.two() <= 9){ gasGiant = true; }  // this is in Book 2, p.35
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
    if (roll.two(modifier) >= 7){ return true; }
    return false;
  }
  
  Boolean generateNavalBase(){
    if (uwp.starport == 'A' || uwp.starport == 'B'){ 
      if (roll.two() >= 8){ return true; }
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
  
  System_CT81(Coordinate _coord, float _density){
    super(_coord, _density);
    
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
    return new TradeClass_CT81(_uwp);   
  }
  
  UWP generateUWP(JSONObject _json){
    return new UWP(_json);
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
      if (roll.two() < 11){
        return "Red";
      }
    }
    
    int dieThrow = roll.two();
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

  Star primary;
  Habitable mainworld;
  int gasGiantCount;
  Boolean militaryBase = false;
  OrbitBuilder builder;
  
  System_ScoutsEx(Coordinate _coord, float _density){
    super(_coord, _density);
    println("occupied = " + occupied);
    println("In System_ScoutsEx ctor after super() call");
    
    if (occupied){
      builder = ruleset.newOrbitBuilder();          // TO_DO: do we need to keep the builder around after this point?
      builder.newStar(this);                   // could just do (new StarBuilder()).newStar(this) instead
      println("\n--------------\nSystem: " + name + " (" + coord + ")");
      println("Primary: " + primary);      
      
      countGasGiants();
      
      println("@@@ System_ScoutsEx ctor");
      
      uwp = mainworld.getUWP();                 
      navalBase = generateNavalBase();          // need to regenerate with the 'true' mainworld UWP - otherwise identical to CT77 
      scoutBase = generateScoutBase();          
      trade = generateTradeClass(uwp);
      travelZone = generateTravelZone();      
      generateFacilities();
                                                
      println("PRIMARY : " + primary);
      println(primary.orbits);
      ArrayList<Star> comps = primary.getCompanions();
      if (comps.size() > 0){
        for (Star c : comps){
          println("COMPANION : " + c);
          println(c.orbits);
        }
      }
      println("MAINWORLD: " + mainworld);
    }
  }

  System_ScoutsEx(JSONObject _json){
    super(_json);
    
    if (occupied){
      primary = new Star(this, _json.getJSONObject("Primary"));
      countGasGiants();
      // TO_DO: mainworld
      
      println(this);
      
      uwp = new UWP_ScoutsEx(this.mainworld, _json.getJSONObject("UWP"));
      
      militaryBase = _json.getBoolean("Military Base");
    }
  }

  UWP generateUWP(){    
    UWP u = null;
    
    println("@@@ System_ScoutsEx.generateUWP()");
    println(this.getClass());
    
    //try {
      //u = ruleset.newUWP(new Star(this));         // this is a hack solution - only used
      //u = ruleset.newUWP(new Planet(new Star(this), 3, "H", null));         // this is a hack solution - only used
      u = new UWP_ScoutsEx("X000000-0");
      
      
      
    //} catch(InvalidUWPInvocation _e) {            // during super ctor and discarded, so we can create a bogus star
    //  println("Invalid call to ruleset.newUWP");  // really should clean this design up
    //  exit();
    //}
    
    println("@@ Exiting System_ScoutsEx.generateUWP()");
    
    return u;
  }

  void countGasGiants(){
    ArrayList gasGiants = primary.getAll(GasGiant.class);
    
    if (gasGiants.size() > 0){
      gasGiant = true;
      gasGiantCount = gasGiants.size();
    } else {
      gasGiant = false;
      gasGiantCount = 0;
    }
  }
  
  void generateFacilities(){
    int additionalNavalBases = 0;
    if (navalBase){
      mainworld.addFacility("Naval Base");
      additionalNavalBases = roll.one(-3);
      if (additionalNavalBases < 0){ additionalNavalBases = 0; }
    }
    
    int additionalScoutBases = 0;
    if (scoutBase){
      mainworld.addFacility("Scout Base");
      additionalScoutBases = roll.one(-4);
      if (additionalScoutBases < 0){ additionalScoutBases = 0; }
    }
    
    for (Habitable h : primary.getAll(Habitable.class)){
      if (h.isMainworld()){ continue; }
      
      // Scouts p. 37 - base facilities at other planets in the system
      if (navalBase && additionalNavalBases > 0 && h.getUWP().pop > 2){
        h.addFacility("Naval Facility");
        additionalNavalBases--;
      }

      if (scoutBase && additionalScoutBases > 0 && h.getUWP().pop > 1){
        h.addFacility("Scout Facility");
        additionalScoutBases--;
      }
      
      // Scouts p. 38 - other subordinate facilities
      // Farming
      if (((Orbit)h).isHabitableZone() && 
          h.getUWP().atmo  > 3 &&
          h.getUWP().atmo  < 10 &&
          h.getUWP().hydro > 3 &&
          h.getUWP().hydro < 9 &&
          h.getUWP().pop   > 1){
            h.addFacility("Farming");
      }
      
      // Mining
      if (this.trade.industrial &&
          h.getUWP().pop   > 1){
            h.addFacility("Mining");
      }
      
      // Colony
      if (h.getUWP().gov == 6 &&
          h.getUWP().pop > 4){
            h.addFacility("Colony");
      }
      
      // Research Lab
      if (mainworld.getUWP().tech > 8 && mainworld.getUWP().pop > 0){
        int modifier = 0;
        if (mainworld.getUWP().tech > 9){ modifier += 2; }
        int dieThrow = roll.two(modifier);
        if (dieThrow > 10){
          h.addFacility("Research Lab");
          if (h.getUWP().tech < mainworld.getUWP().tech){
            h.getUWP().tech = mainworld.getUWP().tech;
          }
        }
      }
      
      // Military Base
      if (!this.trade.poor && h.getUWP().pop > 0){
        int modifier = 0;
        if (mainworld.getUWP().pop > 7){ modifier += 1; }
        if (mainworld.getUWP().atmo == h.getUWP().atmo){ modifier += 2; }
        int dieThrow = roll.two(modifier);
        if (dieThrow > 11){
          h.addFacility("Military Base");
          militaryBase = true;
          if (h.getUWP().tech < mainworld.getUWP().tech){
            h.getUWP().tech = mainworld.getUWP().tech;
          }
        }        
      }
    }
  }
  
  String toString(){
    String description = super.toString();
    if (occupied){
      description += primary.getSpectralType() + " ";
      if (primary.closeCompanion != null){ description += primary.closeCompanion.getSpectralType() + " "; }
      
      ArrayList<Star> comps = primary.getCompanions();
      for (Star s : comps){
        description += s.getSpectralType() + " ";
      }
      
      String firstHalf = description.substring(0, 35);
      String secondHalf = description.substring(35, description.length());

      String mb = " ";
      if (militaryBase){ mb = "M"; } // from Scouts p. 38: "Often, a military base can be noted with the symbol M in the base column of the statistics for the system"

      description = firstHalf + mb + secondHalf;
    }
    return description;
  }
  
  String list(){
    String result = "";
    if (occupied){
      result += this.toString() + "\n";
      result += "Primary: " + primary.toString() + "\n";
      for (Orbit o : primary.getAll(Orbit.class)){
        if (o.orbitNumber == -1){ continue; }
        for (int i = 0; i < o.orbitDepth - 1; i++){
          result += "   ";
        }
        result += o.offsetOrbitNumber + " " + o + " " + o.orbitalZone + "\n";
      }
    } else {
    }
    return result;
  }
  
  JSONObject asJSON(){
    JSONObject json = super.asJSON();
    if (occupied){
      JSONObject star = primary.asJSON();
      json.setJSONObject("Primary", star);
      json.setBoolean("Military Base", militaryBase);
      json.setFloat("Mainworld",((Orbit)mainworld).orbitNumber);
    }
    return json;
  }
}