// Universal World Profile
// this is derived from CT77 Book 3
class UWP {
  char starport;
  int size, atmo, hydro, pop, gov, law, tech; 
  Dice roll;
  
  UWP(){
    roll = new Dice();
    
    starport = generateStarport();
    size     = generateSize();
    atmo     = generateAtmo();
    hydro    = generateHydro();
    pop      = generatePop();
    gov      = generateGov();
    law      = generateLaw(); 
    tech     = generateTech();
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
  
  int generateSize(){ return roll.two(-2); }
  
  int generateAtmo(){
    int result = roll.two(size - 7);
    if (size == 0 || result < 0){ result = 0; }
    return result;
  }
  
  int generateHydro(){
    int result = roll.two(size - 7);
    if (atmo <= 1 || atmo >= 10){ result -= 4; }
    if (size <= 1 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }

  int generatePop(){ return roll.two(-2); }
  
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

class UWP_CT81 extends UWP {
  UWP_CT81(){
    super();

    // starport identical to CT77
    // size identical to CT77
    // atmo identical to CT77
    
    // hydro slightly different - see override below
   
    // pop identical to CT77
    // gov identical to CT77
    // law identical to CT77
    // tech identical to CT77
  }
  
  UWP_CT81(JSONObject _json){
    super(_json);
  }

  // size 1 worlds are no longer forced to 0 hydro
  // discrepancy between text (p. 7) and summary table (p. 12):
  //  - table is identical to CT77 (other than change above)
  //  - text adds ATMO instead of SIZE; using that here
  int generateHydro(){
    int result    = roll.two(atmo - 7);
    if (atmo <= 1 || atmo >= 10){ result -= 4; }
    if (size == 0 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }
}

class UWP_ScoutsEx extends UWP {
  Orbit planet;  // only used during ctor? should we pass in to methods rather than have a field?
  
  UWP_ScoutsEx(){}
  
  UWP_ScoutsEx(Orbit _planet){
    // need to unravel inheritance problem
    //  super ctor is automatically called before any of this
    //  but with the overloaded methods extending the template, 
    //  we have null pointers to worry about
    planet = _planet;
    size  = generateSize();
    atmo  = generateAtmo();
    hydro = generateHydro();
    pop   = generatePop();

    // stubbing out following for the time being
    starport = 'X';
    gov      = 0;
    law      = 0; 
    tech     = 0; 
  }
  
  UWP_ScoutsEx(JSONObject _json){
    super(_json);
  }
  
  int generateSize(){
    if (planet == null){ return super.generateSize(); }  // hacky approach to deal with automatic call to super ctor
    if (planet.isPlanetoid()){ return 0; }

    int modifier = 0;
    if (planet.orbitNumber == 0  ){ modifier -= 5; }
    if (planet.orbitNumber == 1  ){ modifier -= 4; }
    if (planet.orbitNumber == 2  ){ modifier -= 2; }
    if (planet.isOrbitingClassM()){ modifier -= 2; }
    int result = roll.two(modifier - 2);  
    
    if (result <= 0){ result = 0; }

    return result;
  }
  
  int generateAtmo(){
    if (planet == null){ return super.generateAtmo(); }  // see note above in generateSize()
    
    int modifier = 0;
    if (planet.isInnerZone()){ modifier -= 2; }
    if (planet.isOuterZone()){ modifier -= 4; }
    
    int result = roll.two(size + modifier - 7);
    if (size == 0 || result < 0){ result = 0; }   // includes size 'S' (numerically zero)
    
    if (planet.isAtLeastTwoBeyondHabitable() &&
        roll.two() == 12){ return 10; }    
    
    return result;    
  }
  
  // Scouts reverts to +Size as a modifier
  int generateHydro(){
    if (planet == null){ return super.generateHydro(); }  // see note above in generateSize()

    if (planet.isInnerZone()){ return 0; }
    if (size <= 1           ){ return 0; }   // includes size 'S' (numerically zero)

    int modifier = 0;
    if (planet.isOuterZone()   ){ modifier -= 2; }
    if (atmo <= 1 || atmo >= 10){ modifier -= 4; }
     
    int result = roll.two(size + modifier - 7);
    result = constrain(result, 0, 10);    
    
    return result;    
  }
  
  int generatePop(){
    if (planet == null){ return super.generatePop(); }  // see note above in generateSize()
    
    int modifier = 0;
    if (planet.isInnerZone()     ){ modifier -= 5; }
    if (planet.isOuterZone()     ){ modifier -= 3; }
    if (!(atmo == 0 || atmo == 5 ||
          atmo == 6 || atmo == 8)){ modifier -= 2; }
     
    int result = roll.two(modifier - 2);
    if (result < 0){ result = 0; }
    
    return result;
  }
  
  String toString(){
    String result = super.toString();
    if (size == 0 && !planet.isPlanetoid()){
      result = result.substring(0,1) + "S" + result.substring(2, result.length());  // Scouts introduced size 'S' small worlds (as contrasted with size 0 planetoid belts)
    }
    return result;
  }
  
  UWP fromString(String _uwp){  // could/should this be in the parent class instead? only really need the subclass stuff during construction. 
    // leave planet field as null - should only be needed during original construction, and would prevent pulling up the hierarchy (moot if we use parent class)
    UWP u = new UWP();
    u.starport = _uwp.charAt(0);
    u.size     = unhex(_uwp.substring(1,2));
    u.atmo     = unhex(_uwp.substring(2,3));
    u.hydro    = unhex(_uwp.substring(3,4));
    u.pop      = unhex(_uwp.substring(4,5));
    u.gov      = unhex(_uwp.substring(5,6));
    u.law      = unhex(_uwp.substring(6,7));
    u.tech     = unModifiedHexChar(_uwp.substring(8,9)); // skip the dash character, and handle Traveller eHex
    return u;
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