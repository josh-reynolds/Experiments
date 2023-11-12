// CT77 Book 3 pp. 1-12 
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
  
  System(Coordinate _coord){
    coord = _coord;
    hex = new Polygon(coord.getScreenX(), coord.getScreenY(), hexRadius);
    roll = new Dice();
  }
    
  System(Coordinate _coord, Boolean _occupied){
    this(_coord);
    occupied = _occupied;
    
    if (occupied){
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
    this(new Coordinate(_json.getJSONObject("Coordinate")));
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
  
  TradeClass generateTradeClass(UWP _uwp){ return ruleset.newTradeClass(_uwp, this); }

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
  
  String paddedSystemName(){
    String outputName = name;
    if (name.length() >= 15){ outputName = name.substring(0,15); }
    int paddingLength = (16 - outputName.length());
    for (int i = 1; i <= paddingLength; i++){
      outputName += " ";
    }
    return outputName;
  }
  
  String systemFeatures(){
    String nb = " ";
    if (navalBase){ nb = "N"; }
    
    String sb = " ";
    if (scoutBase){ sb = "S"; }
    
    String gg = " ";
    if (gasGiant){ gg = "G"; }
    
    return nb + sb + gg;
  }
  
  String occupiedSystemString(){
    return paddedSystemName() + coord.toString() + " : " + uwp.toString() + " " + systemFeatures() + " " + trade.toString();
  }
  
  String emptySystemString(){
    return "EMPTY : " + coord.toString();
  }
  
  String toString(){
    if (occupied){
      return occupiedSystemString();
    } else {
      return emptySystemString();
    }
  }
  
  String extendedString(){
    return this.toString();
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
  
  System_CT81(Coordinate _coord){ super(_coord); }
  
  System_CT81(Coordinate _coord, Boolean _occupied){
    super(_coord, _occupied);
    
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

  String travelZoneString(){ 
    if (travelZone.equals("Red")){ return " R "; }
    if (travelZone.equals("Amber")){ return " A "; }
    return "   ";
  }

  String occupiedSystemString(){
    return paddedSystemName() + coord.toString() + " : " + uwp.toString() + " " + systemFeatures() + travelZoneString() + trade.toString();
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
  int populationMultiplier;

  System_ScoutsEx(Coordinate _coord, Boolean _occupied){
    super(_coord);
    occupied = _occupied;
    
    if (occupied){
      name = lines[floor(random(lines.length))];
      routes = new ArrayList<Route>();
      
      ruleset.newOrbitBuilder().newPrimary(this);
      println("\n--------------\nSystem: " + name + " (" + coord + ")");
      
      countGasGiants();     
      uwp = mainworld.getUWP();                 
      navalBase = generateNavalBase();          // need to generate with the 'true' mainworld UWP - otherwise identical to CT77 
      scoutBase = generateScoutBase();          
      populationMultiplier = generatePopulationMultiplier();
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
      println("--------------\n");
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

  // this value isn't used in Scouts - it was officially introduced in MegaTraveller
  //  however it's useful to have here to smoothly mesh with ctor flow
  //  (motivation is to prevent a null exception in generateTradeClass())
  // MTRM p. 25 - though note that RAW generates values from 0-9
  //   since this is a multiplier, a 0 value would remove all population
  //   adjusting this to a 1-9 range
  int generatePopulationMultiplier(){ return floor(random(1,10)); }

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

  void assessFarming(Habitable _h){
    if (((Orbit)_h).isHabitableZone() && 
        _h.getUWP().atmo  > 3 &&
        _h.getUWP().atmo  < 10 &&
        _h.getUWP().hydro > 3 &&
        _h.getUWP().hydro < 9 &&
        _h.getUWP().pop   > 1){
          _h.addFacility("Farming");
    }
  }
  
  void assessMining(Habitable _h){
    if (this.trade.industrial &&
        _h.getUWP().pop   > 1){
          _h.addFacility("Mining");
    }
  }
  
  void assessColony(Habitable _h){
    if (_h.getUWP().gov == 6 &&
        _h.getUWP().pop > 4){
          _h.addFacility("Colony");
    }
  }
  
  void assessResearchLab(Habitable _h){
    if (mainworld.getUWP().tech > 8 && mainworld.getUWP().pop > 0){
      int modifier = 0;
      if (mainworld.getUWP().tech > 9){ modifier += 2; }
      int dieThrow = roll.two(modifier);
      if (dieThrow > 10){
        _h.addFacility("Research Lab");
        adjustTechLevel(_h);
      }
    }
  }
  
  void assessMilitaryBase(Habitable _h){
    if (!this.trade.poor && _h.getUWP().pop > 0){
      int modifier = 0;
      if (mainworld.getUWP().pop > 7){ modifier += 1; }
      if (mainworld.getUWP().atmo == _h.getUWP().atmo){ modifier += 2; }
      int dieThrow = roll.two(modifier);
      if (dieThrow > 11){
        _h.addFacility("Military Base");
        militaryBase = true;
        adjustTechLevel(_h);
      }        
    }
  }
  
  void adjustTechLevel(Habitable _h){
    // for Research Lab + Military Base only
    if (_h.getUWP().tech < mainworld.getUWP().tech){
      _h.getUWP().tech = mainworld.getUWP().tech;
    }    
  }
  
  int assessNavalBases(Habitable _h, int _additionalNavalBases){    
    if (navalBase && _additionalNavalBases > 0 && _h.getUWP().pop > 2){
      _h.addFacility("Naval Facility");
      _additionalNavalBases--;
    }
    return _additionalNavalBases;
  }
  
  int assessScoutBases(Habitable _h, int _additionalScoutBases){
    if (scoutBase && _additionalScoutBases > 0 && _h.getUWP().pop > 1){
      _h.addFacility("Scout Facility");
      _additionalScoutBases--;
    }
    return _additionalScoutBases;
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
      additionalNavalBases = assessNavalBases(h, additionalNavalBases);
      additionalScoutBases = assessScoutBases(h, additionalScoutBases);
      
      // Scouts p. 38 - other subordinate facilities     
      assessFarming(h);
      assessMining(h);
      assessColony(h);
      assessResearchLab(h);
      assessMilitaryBase(h);      
    }
  }
  
  String starString(){
    String description = primary.getSpectralType() + " ";
    if (primary.closeCompanion != null){ description += primary.closeCompanion.getSpectralType() + " "; }
    
    ArrayList<Star> comps = primary.getCompanions();
    for (Star s : comps){
      description += s.getSpectralType() + " ";
    }
    return description;
  }

  String systemFeatures(){
    String nb = " ";
    if (navalBase){ nb = "N"; }
    
    String sb = " ";
    if (scoutBase){ sb = "S"; }

    String mb = " ";
    if (militaryBase){ mb = "M"; } // from Scouts p. 38: "Often, a military base can be noted with the symbol M in the base column of the statistics for the system"    
    
    String gg = " ";
    if (gasGiant){ gg = "G"; }
    
    return nb + sb + mb + gg;
  }  
  
  String occupiedSystemString(){
    return paddedSystemName() + coord.toString() + " : " + uwp.toString() + " " + systemFeatures() + travelZoneString() + trade.toString() + starString();
  }
  
  String proseDescription(){ return ""; }  // stub to allow override in subclasses
  
  String list(){
    String result = "";
    if (occupied){
      result += this.toString() + "\n";
      result += proseDescription();
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

class System_MT extends System_ScoutsEx {
  int planetoidCount;
  
  System_MT(Coordinate _coord, Boolean _occupied){ 
    super(_coord, _occupied);

    if (occupied){ countPlanetoids(); }  
  } 

  // MegaTraveller adds a 'Travel Zone matrix' that supplements referee fiat (MTRM p. 25)
  // New Era uses the same table (T:NE p. 187)
  String generateTravelZone(){
    String result = super.generateTravelZone();
    
    if (result.equals("Red")){ return result; }
    
    if (uwp.gov == 13 && uwp.law > 19){ return "Red"; }
    if (uwp.gov == 14 && uwp.law > 18){ return "Red"; }  
    if (uwp.gov == 15 && uwp.law > 17){ return "Red"; }
    
    if (result.equals("Amber")){ return result; }
    
    if (uwp.gov == 10 && uwp.law > 19){ return "Amber"; }
    if (uwp.gov == 11 && uwp.law > 18){ return "Amber"; }
    if (uwp.gov == 12 && uwp.law > 17){ return "Amber"; }
    if ((uwp.gov == 13 || uwp.gov == 14) && uwp.law > 16){ return "Amber"; }
    if (uwp.gov == 15 && uwp.law > 15){ return "Amber"; }

    return "Green";
  }
 
  // initial implementation was including Rings in this count due to class hierarchy (a Ring is-a Planetoid)
  //  that seems off - haven't found a canonical example to prove it,
  //  but I am adjusting
  void countPlanetoids(){    
    ArrayList planetoids = primary.getAll(Planetoid.class);
    
    if (planetoids.size() > 0){
      planetoidCount = planetoids.size();
    } else {
      planetoidCount = 0;
    }

    ArrayList rings = primary.getAll(Ring.class);
    planetoidCount -= rings.size();
    if (planetoidCount < 0){ planetoidCount = 0; }
  }
 
 // MegaTraveller changes the procedure for subordinate facilities slightly (MTRM p. 29)
 // New Era follows the same procedure (T:NE p. 195)
 void generateFacilities(){
    if (navalBase){ mainworld.addFacility("Naval Base"); }
    if (scoutBase){ mainworld.addFacility("Scout Base"); }
    
    for (Habitable h : primary.getAll(Habitable.class)){
      if (h.isMainworld()){ continue; }
      
      // MTRM p. 29 - Naval/Scout bases only depend on sub pop now, no random count
      if (navalBase && h.getUWP().pop > 2){                
        h.addFacility("Naval Facility");
        if (h.getUWP().tech < mainworld.getUWP().tech){
          h.getUWP().tech = mainworld.getUWP().tech;
        }
      }
      if (scoutBase && h.getUWP().pop > 1){ h.addFacility("Scout Facility"); }
      
      // MTRM p. 29 - Farming/Mining/Colony/Research Lab identical to Scouts      
      assessFarming(h);
      assessMining(h);
      assessColony(h);
      assessResearchLab(h);
      
      // MTRM p. 29 - Military Base changed from scouts, method overriden
      assessMilitaryBase(h); 
    }  
  }
  
  // MTRM p. 29 - Military Base only for pop 8+ mainworlds now, no longer requirement for population on subordinate world
  // New Era is the same (including the errata typo) (T:NE p. 195)
  void assessMilitaryBase(Habitable _h){
    if (!this.trade.poor && mainworld.getUWP().pop > 7){
      int modifier = 0;
      if (mainworld.getUWP().pop > 7){ modifier += 1; }                  // always applies because of the earlier condition
      if (mainworld.getUWP().atmo == _h.getUWP().atmo){ modifier += 2; } // typo here - the value is missing; assume same as Scouts (+2) (confirmed errata p. 22)
      int dieThrow = roll.two(modifier);
      if (dieThrow > 11){
        _h.addFacility("Military Base");
        militaryBase = true;
        adjustTechLevel(_h);
      }        
    }
  }

  // for MegaTraveller we will have (MTRM p. 16):
  //   name coord UWP bases trade travel-popmult-planetoid-gasgiant allegiance
  // this drops the star data, and adds pop/planetoid/gasgiant counts
  // I'm not yet touching allegiance so we'll leave that alone
  String occupiedSystemString(){
    return paddedSystemName() + coord.toString() + " : " + uwp.toString() + " " + systemFeatures() + " " + paddedTradeString() + systemData();
  }

  // padding to four codes (two letters + space each) - so 12 characters long
  //  tested against multiple subsectors, found no instances with more than four trade codes
  //  method below includes truncation to handle this scenario, might be worth some analysis
  //  to see if it's even possible to get five+ codes under MT rules
  // TO_DO: assess whether this should live in TradeClass... implement here for now
  // TO_DO: heavy duplication from padded system name method above, refactor - common service living where?
  String paddedTradeString(){
    String tradeString = trade.toString();
    if (tradeString.length() > 12){                                // leave truncation in? handles any codes over four, but how will we know? 
      println("@@@ TRUNCATING tradeString (" + tradeString + ")"); // temporarily flag so we can see how common/severe the issue might be
      tradeString = tradeString.substring(0,11);                   // my assumption is this is rare
    }
    int paddingLength = (12 - tradeString.length());
    for (int i = 1; i <= paddingLength; i++){
      tradeString += " ";
    }
    return tradeString;
  }

  // (the Spinward Marches data in Imperial Encyclopedia (MTIE pp. 94-7) is slightly different)
  //   coord UWP base trade/remarks zone-popmult-planetoid-gasgiant-allegiance stars
  // in this scheme, base is a single-letter code that packs together multiple combinations
  //  'remarks' are additional non-trade codes, like Imperial Research Stations
  //  not pursuing this alternate format for now

  // In MegaTraveller, gas giant count is included in the summary line, no need for a code here
  String systemFeatures(){
    String nb = " ";
    if (navalBase){ nb = "N"; }
    
    String sb = " ";
    if (scoutBase){ sb = "S"; }

    String mb = " ";
    if (militaryBase){ mb = "M"; }    
    
    return nb + sb + mb;
  }

  // note that errata p. 21 states that planetoid & gasgiant were reversed in RAW (on MTRM p. 16)
  //  (on review this must refer to an earlier printing - my copy doesn't show this and matches the 
  //   errata version, implemented below)
  String systemData(){
    return travelZoneString() + str(populationMultiplier) + hex(planetoidCount,1) + hex(gasGiantCount,1);
  }
  
  String travelZoneString(){ 
    if (travelZone.equals("Red")){ return "R"; }
    if (travelZone.equals("Amber")){ return "A"; }
    return " ";
  }
  
  String proseDescription(){ return ((UWP_MT)uwp).homeworldDescription() + "\n"; }
}

// TO_DO: very likely will shift this over to the Scouts branch once we add orbits, keeping simple for now 
class System_T5 extends System_CT81 {
  int importance;   // extensions have formatting, so will probably break these out into separate classes...
  int resources;
  int labor;
  int infrastructure;
  int efficiency;
  int homogeneity;
  int acceptance;
  int strangeness;
  int symbols;
  String natives;  // not sure how to represent this yet, let's start with a simple string
  
  System_T5(Coordinate _coord, Boolean _occupied){
    super(_coord, _occupied);
    
    if (occupied){ 
      importance = calculateImportance();
      resources = calculateResources();
      labor = calculateLabor();
      infrastructure = calculateInfra();
      efficiency = calculateEfficiency();
      homogeneity = calculateHomogeneity();
      acceptance = calculateAcceptance();
      strangeness = calculateStrangeness();
      symbols = calculateSymbols();
      
      natives = determineNativeLife();
    }
  }

  System_T5(JSONObject _json){
    super(_json);
    
    // TO_DO: add extensions to JSON
  }
  
  // table from T5 p. 435
  int calculateImportance(){
    int result = 0;

    if (uwp.starport == 'A' || uwp.starport == 'B'                       ){ result += 1; }
    if (uwp.starport == 'D' || uwp.starport == 'E' || uwp.starport == 'X'){ result -= 1; }
    
    if (uwp.tech >= 10){ result += 1; }
    if (uwp.tech <= 8 ){ result -= 1; }

    TradeClass_T5 t = (TradeClass_T5)trade;
    if (t.agricultural){ result += 1; }
    if (t.highpop     ){ result += 1; }
    if (t.industrial  ){ result += 1; }
    if (t.rich        ){ result += 1; }
    
    if (uwp.pop <= 6){ result -= 1; }
    
    if (navalBase && scoutBase){ result += 1; }   
    
    // TO_DO: Way Station also grants +1, but no procedure for assigning, seems to be fiat
    //  p. 432 notes: "Possible Depot or Way Station" under Starport A
    //  p. 436 notes: "about 1 per 50 parsecs along major trade routes"
    
    return result;
    
  }
  
  // TO_DO: requires gasgiant + planetoid counts, not present in this leg of the hierarchy, need to add
  //  also may be a timing issue - we generate extensions before orbits, need to defer this calculation...
  int calculateResources(){
    int result = 0;
    result += roll.two();
    if (uwp.tech >= 8){ 
      //result += gasGiantCount + planetoidCount;  
    }
    return result;
  }
  
  int calculateLabor(){ 
    if (uwp.pop == 0){ 
      return 0; 
    } else {
      return uwp.pop - 1;
    }
  }
  
  int calculateInfra(){
    TradeClass_T5 t = (TradeClass_T5)trade;
    if (t.barren || t.dieback || t.lowpop){ return 0; }
    
    int result = 0;
    if (t.nonindustrial){
      result += roll.one(importance);
    } else {
      result += roll.two(importance);
    }
    
    if (result <= 0){
      return 0;
    } else {
      return result;
    }
  }
  
  int calculateEfficiency(){
    return roll.one() - roll.one();  
  }

  int calculateHomogeneity(){
    int result = uwp.pop + roll.one() - roll.one();
    if (result <= 1){ result = 1; }
    return result;
  }
  
  int calculateAcceptance(){
    int result = uwp.pop + importance;
    if (result <= 1){ result = 1; }
    return result;
  }
  
  int calculateStrangeness(){
    int result = 5 + roll.one() - roll.one();
    if (result <= 1){ result = 1; }
    return result; 
  }
  
  int calculateSymbols(){
    int result = uwp.tech + roll.one() - roll.one();
    if (result <= 1){ result = 1; }
    return result; 
  }  

  // table on T5 p. 436 - clearer version on p. 538
  // this messy, look for ways to clean up the logic once it's working
  String determineNativeLife(){
    String result = "";
    
    int popClass = 0; // pop 0 && tech 0
    if (uwp.pop == 0 && uwp.tech > 0){ popClass = 1; }
    if (uwp.pop >= 1 && uwp.pop <= 3){ popClass = 2; }
    if (uwp.pop >= 4 && uwp.pop <= 6){ popClass = 3; }
    if (uwp.pop >= 7){ popClass = 4; }
    
    int atmoClass = 0; // atmo 0,1
    if ((uwp.atmo >= 2 && uwp.atmo <= 9) || (uwp.atmo >= 13 && uwp.atmo <= 15)){ atmoClass = 1; }
    if (uwp.atmo >= 10 && uwp.atmo <= 12){ atmoClass = 2; }
    
    switch(popClass){
      case 0:
        switch(atmoClass){
          case 0:
            // no value
            break;
          case 1:
            result = "Extinct Natives";
            break;
          case 2:
            result = "Extinct Exotic Natives";
        }
        break;
      case 1:
        switch(atmoClass){
          case 0:
            result = "Vanished Transplants";
            break;
          case 1:
            result = "Catastrophic Extinct Natives";
            break;
          case 2:
            result = "Catastrophic Extinct Exotic Natives";
        }
        break;      
      case 2:
        result = "Transients";
        break;      
      case 3:
        result = "Settlers";
        break;      
      case 4:
        switch(atmoClass){
          case 0:
            result = "Transplants";
            break;
          case 1:
            result = "Natives";
            break;
          case 2:
            result = "Exotic Natives";
        }
        break;
    }
    
    if (uwp.gov == 1){ result = "Corporate"; }
    if (uwp.gov == 6){ result = "Colonists"; }
    
    return result;
  }
  
  String importanceString(){
    String sign = "+";
    if (importance < 0){ sign = ""; }   
    return " {" + sign + importance + "} ";
  }
  
  String economicString(){
    String sign = "+";
    if (efficiency < 0){ sign = ""; }
    return "(" + hex(resources, 1) + hex(labor, 1) + hex(infrastructure, 1) + sign + efficiency + ") ";
  }
 
  String cultureString(){
    return "[" + hex(homogeneity, 1) + hex(acceptance, 1) + hex(strangeness, 1) + hex(symbols, 1) + "] ";
  }
 
  // T5 p. 428,435: "if any value = 0, use 1 (to avoid multiplying by 0)" 
  int resourceUnits(){
    int r = max(1, resources);
    int l = max(1, labor);
    int i = max(1, infrastructure);
    int e = efficiency;
    if (e == 0){ e = 1;}
    return r * l * i * e;
  }
 
  // full format is on T5 p. 431 - deviating from that for now
  //  also, the extensions are pushing the Trade Classes off-screen, probably need to break this apart
  //  one format for the subsector summary, and another with all the details for console output, text files, detail screens, etc.
  String occupiedSystemString(){
    return paddedSystemName() + coord.toString() + " : " + uwp.toString() + " " + systemFeatures() + travelZoneString() + trade.toString();
  }
  
  String extendedString(){
    return paddedSystemName() + coord.toString() + " : " + uwp.toString() + " " + systemFeatures() + travelZoneString() + importanceString() + economicString() + resourceUnits() + "RU " + cultureString() + natives + " " + trade.toString();  
  }
}