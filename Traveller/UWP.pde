// Universal World Profile
// this is derived from CT77 Book 3
class UWP {
  char starport;
  int size, atmo, hydro, pop, gov, law, tech; 
  Dice roll;

  UWP(){}  // need to define default ctor for subclasses
  
  UWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    roll = new Dice();   // temporary scaffolding while we refactor this away
    
    starport = _starport;
    size     = _size;
    atmo     = _atmo;
    hydro    = _hydro;
    pop      = _pop;
    gov      = _gov;
    law      = _law; 
    tech     = _tech;
  }
  
  UWP(JSONObject _json){
    starport = _json.getString("Starport").charAt(0);
    size     = _json.getInt("Size");
    atmo     = _json.getInt("Atmosphere");
    hydro    = _json.getInt("Hydrographics");
    pop      = _json.getInt("Population");
    gov      = _json.getInt("Government");
    law      = _json.getInt("Law Level");
    tech     = _json.getInt("Tech Level");
  }
    
  char generateStarport(){
    int dieThrow = roll.two();
    
    switch(dieThrow){
      case 2:
      case 3:
      case 4:
        return 'A';
      case 5:
      case 6:
        return 'B';
      case 7:
      case 8:
        return 'C';
      case 9:
        return 'D';
      case 10:
      case 11:
        return 'E';
      case 12:
        return 'X';
      default:
        println("Invalid result in generateStarport()");
        return 'Z';
    }
  }
  
  int generateGov(){
    int result = roll.two(pop - 7);
    if (result < 0){ result = 0; }
    return result;
  }

  int generateLaw(){
    int result = roll.two(gov - 7);
    if (result < 0){ result = 0; }
    return result;
  }
  
  int generateTech(){
    int modifier = 0;
    
    if (starport == 'A'){ modifier += 6; }
    if (starport == 'B'){ modifier += 4; }
    if (starport == 'C'){ modifier += 2; }
    if (starport == 'X'){ modifier -= 4; }
    
    if (size <= 1){             modifier += 2; }
    if (size > 1 && size <= 4){ modifier += 1; }
    
    if (atmo <= 3 || atmo >= 10){ modifier += 1; }
    
    if (hydro == 9){  modifier += 1; }
    if (hydro == 10){ modifier += 2; }
    
    if (pop >= 1 && pop <= 5){ modifier += 1; }
    if (pop == 9){             modifier += 2; }
    if (pop == 10){            modifier += 4; }
    
    if (gov == 0 || gov == 5){ modifier += 1; }
    if (gov == 13){            modifier -= 2; }
    
    return roll.one(modifier);
  }
  
  // Traveller uses hexadecimal to get single-digit utility,
  // but occasionally allows values to go above 15 (F)
  // so there is an 'extended hex' scheme, excluding 'I' + 'O' to 
  // avoid confusion with '1' + '0'
  String modifiedHexChar(int _value){
    if (_value <= 15){ return hex(_value, 1); }
    switch(_value){
      case 16:
        return str('G');
      case 17:
        return str('H');
      case 18:
        return str('J');
      case 19:
        return str('K');
      case 20:
        return str('L');
      case 21:
        return str('M');
      case 22:
        return str('N');
      default:
        println("Invalid input to modifiedHexChar()");
        return str('Q');
    }
  }
  
  String toString(){
    return starport + hex(size, 1) + hex(atmo, 1) + 
                      hex(hydro, 1) + hex(pop, 1) +
                      hex(gov, 1) + hex(law, 1) +
                      "-" + modifiedHexChar(tech);
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    json.setString("Starport", str(starport));
    json.setInt("Size", size);
    json.setInt("Atmosphere", atmo);
    json.setInt("Hydrographics", hydro);
    json.setInt("Population", pop);
    json.setInt("Government", gov);
    json.setInt("Law Level", law);
    json.setInt("Tech Level", tech);
    return json;
  }
}

class UWP_ScoutsEx extends UWP {
  Orbit planet;              // once refactoring is complete, not sure this back-reference will be needed - just the following flag
  Boolean isPlanet = false;  // planet field is also used to format size value for small worlds (size S)
                             // but this causes issues with the system-level UWP when loaded from JSON
                             // adding this flag to persist the relevant information
  
  UWP_ScoutsEx(){}  // need to define default ctor for subclasses
  
  UWP_ScoutsEx(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    super(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
    planet = _o;
    isPlanet = planet.isPlanet();
  }
  
  void completeUWP(Boolean _isMainworld){
    if (_isMainworld){                // for mainworld, gov/law/starport/tech identical to CT77
      gov      = generateGov();
      law      = generateLaw();
      starport = generateStarport();
      tech     = generateTech();
    } else {
      // need backreference to mainworld for the system - Scouts pp. 33 + 38
      //  * subordinate government = 1D, +2 if mainworld gov 7+, 6 if mainworld gov 6; = 0 if pop = 0
      //  * subordinate law = 1D-3 + mainworld law; = 0 if gov = 0
      //  * 'note subordinate facilities'
      //  * subordinate tech level = mainworld tech - 1; = mainworld tech if research lab / military facility
      //  * spaceport type from table, modified by local pop

      System sys;                                // TO_DO: find a better way to plumb this value through, this is kinda ugly
      if (planet.barycenter.isStar()){
        sys = ((Star)planet.barycenter).parent;
      } else {
        sys = ((Star)planet.barycenter.barycenter).parent;
      }
      
      // problem: mainworld is null at this point, not set until the call chain that calls this one completes
      // (Planet(oid).completeUWP() called from Star.designateMainworld()
      // really need to separate and finish the mainworld first, then loop through remainder
      // (in addition to null reference, the final gov/law/etc. fields on the mainworld are needed in this block
      //   put a hack in place upstream in Star.designateMainworld(), will need reworking
      
      Habitable main = ((System_ScoutsEx)sys).mainworld;
      UWP mainUWP = main.getUWP();
      
      gov      = generateSubordinateGov(mainUWP.gov);
      law      = generateSubordinateLaw(mainUWP.law);
      starport = generateSubordinateStarport();           // actually a SPACEport per RAW, but we're sharing a field name w/ mainworlds...
      tech     = generateSubordinateTech(mainUWP.tech);   // will be adjusted later after facilities are generated
    }
  }
  
  UWP_ScoutsEx(Habitable _planet, JSONObject _json){
    super(_json);
    isPlanet = _json.getBoolean("Planet");
    planet = (Orbit)_planet;   // TO_DO: this is always null for the system-level mainworld UWP, remove?
  }
  
  UWP_ScoutsEx(String _uwp){
    starport = _uwp.charAt(0);
    
    String sz = _uwp.substring(1,2); 
    if (sz.equals("S")){
      size = 0;
      isPlanet = true;
    } else {
      size = unhex(sz);
    }

    atmo     = unhex(_uwp.substring(2,3));
    hydro    = unhex(_uwp.substring(3,4));
    pop      = unhex(_uwp.substring(4,5));
    gov      = unhex(_uwp.substring(5,6));
    law      = unhex(_uwp.substring(6,7));
    tech     = unModifiedHexChar(_uwp.substring(8,9)); // skip the dash character, and handle Traveller eHex
  }
  
  int generateSubordinateGov(int _mainworldGov){
    //  * subordinate government = 1D, +2 if mainworld gov 7+, 6 if mainworld gov 6; = 0 if pop = 0
    
    if (pop == 0          ){ return 0; }
    if (_mainworldGov == 6){ return 6; }
    
    int dieThrow = roll.one();
    if (_mainworldGov >= 7){ dieThrow += 2; }
    
    if (dieThrow < 5){
      return dieThrow - 1;
    } else {
      return 6;
    }
  }
  
  int generateSubordinateLaw(int _mainworldLaw){
    //  * subordinate law = 1D-3 + mainworld law; = 0 if gov = 0
    if (gov == 0          ){ return 0; }
    return roll.one(_mainworldLaw - 3);
  }
  
  char generateSubordinateStarport(){
    int modifier = 0;
    if (pop >= 6){ modifier += 2; }
    if (pop == 1){ modifier -= 2; }
    if (pop == 0){ modifier -= 3; }    // text on p. 39 only has the previous two; this one is w/ the table on p. 29
    int dieThrow = roll.one(modifier);
    
    switch(dieThrow){
      case -2:
      case -1:
      case 0:      
      case 1:
      case 2:
        return 'Y';
      case 3:
        return 'H';
      case 4:
      case 5:
        return 'G';
      case 6:
      case 7:
      case 8:
        return 'F';
      default:
        println("Invalid result in generateSubordinateStarport()");
        return 'Z';
    }    
  }
  
  int generateSubordinateTech(int _mainworldTech){
    //  * subordinate tech level = mainworld tech - 1; = mainworld tech if research lab / military facility
    // this value is adjusted once subordinate facilities have been created
    
    return _mainworldTech - 1;
  }
  
  String toString(){
    String result = super.toString();
    if (size == 0 && isPlanet){
      result = result.substring(0,1) + "S" + result.substring(2, result.length());  // Scouts introduced size 'S' small worlds (as contrasted with size 0 planetoid belts)
    }
    return result;
  }

  JSONObject asJSON(){
    JSONObject json = super.asJSON();
    json.setBoolean("Planet", isPlanet);
    return json;
  }
  
  int unModifiedHexChar(String _s){
    int result = 0;
    try {
      result = unhex(_s);
    }
    catch (NumberFormatException _e){
      switch(_s){
        case "G":
          result = 16;
          break;
        case "H":
          result = 17;
          break;
        case "J":
          result = 18;
          break;        
        case "K":
          result = 19;
          break;        
        case "L":
          result = 20;
          break;        
        case "M":
          result = 21;
          break;        
        case "N":
          result = 22;
          break;
        default:
          println("Invalid input to modifiedHexChar()");
      }
    }
    return result;
  }
}