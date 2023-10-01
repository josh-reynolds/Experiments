// Universal World Profile
// this is derived from CT77 Book 3
class UWP {
  char starport;
  int size, atmo, hydro, pop, gov, law, tech; 

  UWP(){}  // need to define default ctor for subclasses
  
  UWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
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

class UWP_MT extends UWP_ScoutsEx {
  UWP_MT(){}  // need to define default ctor for subclasses
  
  UWP_MT(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    super(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }
  
  // from MTPM p. 13
  // some hidden logic in here, the examples on MTPM p. 11 are helpful
  String homeworldDescription(){
    String result = "";
    
    // TO_DO: factor this out into smaller methods
    result += "Starport " + starport + ", ";
    
    if (size == 0           ){ result += "Asteroid, "; }
    if (size > 0 && size < 5){ result += "Small Size, "; } 
    if (size > 4 && size < 8){ result += "Medium Size, "; }
    if (size > 7            ){ result += "Large Size, "; }
    
    if (atmo < 2              ){ result += "Vacuum World, "; }
    if (atmo == 2 || atmo == 3){ result += "Thin Atmosphere, "; }
    if (atmo > 3 && atmo < 7  ){ result += "Standard Atmosphere, "; }
    if (atmo == 7 || atmo == 8){ result += "Dense Atmosphere, "; }
    if (atmo > 8              ){ result += "Exotic Atmosphere, "; }
    
    // from the examples on p. 11, it looks like Hydro should be 
    // omitted for Asteroids (or for Vacuum? but what about Ice-Capped Worlds?
    //  might need to debug their logic, not sure this is consistent
    if (size != 0){
      if (hydro < 2               ){ result += "Desert World, "; }
      if (hydro == 2 || hydro == 3){ result += "Dry World, "; }
      if (hydro > 3 && hydro < 10 ){ result += "Wet World, "; }
      if (hydro == 10             ){ result += "Water World, "; }
    }
    
    if (pop < 2           ){ result += "Low Pop, "; }
    if (pop > 1 && pop < 6){ result += "Mod Pop, "; }
    if (pop > 5           ){ result += "High Pop, "; }
    
    if (law == 0           ){ result += "No Law, "; }
    if (law > 0 && law < 3 ){ result += "Low Law, "; }
    if (law > 2 && law < 8 ){ result += "Mod Law, "; }
    if (law > 7 && law < 10){ result += "High Law, "; }
    if (law > 9            ){ result += "Ext Law, "; }
    
    // TO_DO: these TL descriptions from RAW look off, check errata
    if (tech == 0){ result += "Pre-Industrial"; }
    if (tech > 0 && tech < 3){ result += "Industrial"; }
    if (tech > 2 && tech < 5){ result += "Pre-Stellar"; }
    if (tech > 4 && tech < 7){ result += "Early Stellar"; }
    if (tech > 6 && tech < 9){ result += "Avg Stellar"; }
    if (tech > 8            ){ result += "High Stellar"; }
    // table also includes "Hi Stellar" (sic) for TL 11+ - folding that in with "High Stellar"
    
    return result;
  }
}