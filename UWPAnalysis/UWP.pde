// taking class from Traveller project for some experimentation
// basic UWP generation is taken from CT77

// extending with a population digit, surface area, population density

// some more indices to think about:
//   importance (a la T5 & Pocket Empires)
//   habitability & tech support needed to survive
//   population needed to support tech
//   starport appropriateness - trade barriers? (see Far Trader)
//   population needed to support starport


// Universal World Profile
class UWP {
  char starport;
  int size, atmo, hydro, pop, gov, law, tech; 
  float  popmod;
  long popcount;
  
  float surfaceArea; // needs debugging, don't think it handles size 0 properly
  float popDensity;
  
  
  UWP(){
    starport = generateStarport();
    
    size     = twoDice() - 2;

    atmo     = twoDice() - 7 + size;
    if (size == 0 || atmo < 0){ atmo = 0; }
    
    hydro    = twoDice() - 7 + size;
    if (atmo <= 1 || atmo >= 10){ hydro -= 4; }
    if (size <= 1 || hydro < 0){ hydro = 0; }
    if (hydro > 10) { hydro = 10; }
    
    float totalSurfaceArea = 4 * PI * pow(((float)size/2 * 1000), 2);
    surfaceArea = totalSurfaceArea/10 * (10 - hydro);
    //println(size + " " + hydro + " " + totalSurfaceArea + " " + surfaceArea);
    
    pop      = twoDice() - 2;
    popmod   = random(1,10);
    popcount = (long)(pow(10, pop) * popmod);  
    
    popDensity = popcount/surfaceArea;
    
    gov      = twoDice() - 7 + pop;
    if (gov < 0){ gov = 0; }
    
    law      = twoDice() - 7 + gov;
    if (law < 0){ law = 0; } 
    
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
    
    return oneDie() + modifier;
  }
  
  char generateStarport(){
    int roll = twoDice();
    
    switch(roll){
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

  int oneDie(){
    return floor(random(0,6)) + 1;
  }
  
  int twoDice(){
    return oneDie() + oneDie();
  }
}