// CT77 Book 2 p. 43
class TradeClass {
  Boolean agricultural = false;
  Boolean nonagricultural = false;
  Boolean industrial = false;
  Boolean nonindustrial = false;
  Boolean rich = false;
  Boolean poor = false;
  
  TradeClass(UWP _uwp){
    if (_uwp.atmo  >= 4 && _uwp.atmo  <= 9 &&
        _uwp.hydro >= 4 && _uwp.hydro <= 8 &&
        _uwp.pop   >= 5 && _uwp.pop   <= 7){ agricultural = true; }
        
    if (_uwp.atmo  <= 3 &&
        _uwp.hydro <= 3 &&
        _uwp.pop   >= 6){ nonagricultural = true; }
        
    if ((_uwp.atmo <= 2 || _uwp.atmo == 4 || _uwp.atmo == 7 || _uwp.atmo == 9) &&
        _uwp.pop >= 9){ industrial = true; }
    
    nonindustrial = isNonindustrial(_uwp);

    if (_uwp.gov >= 4 && _uwp.gov <= 9 &&
        (_uwp.atmo == 6 || _uwp.atmo == 8) &&
        _uwp.pop >= 6 && _uwp.pop <= 8){ rich = true; }        
        
    poor = isPoor(_uwp);
  }
  
  // to allow overrides - eventually all of these probably should be turned into methods
  Boolean isNonindustrial(UWP _uwp){ return _uwp.pop <= 6; }
  Boolean isPoor(UWP _uwp){ return (_uwp.atmo >= 2 && _uwp.atmo <= 5 && _uwp.hydro <= 3); }   
  
  String toString(){
    String output = "";
    if (agricultural)   { output += "Ag "; }
    if (nonagricultural){ output += "Na "; }
    if (industrial)     { output += "In "; }
    if (nonindustrial)  { output += "Ni "; }
    if (rich)           { output += "Ri "; }
    if (poor)           { output += "Po "; }
    return output;
  }
}

// CT81 Book 3 p. 16
class TradeClass_CT81 extends TradeClass {
  Boolean water = false;
  Boolean desert = false;
  Boolean vacuum = false;
  Boolean asteroid = false;
  Boolean icecapped = false;
  
  TradeClass_CT81(UWP _uwp){
    super(_uwp);
    
    // agricultural/nonagricultural/industrial/nonindustrial/rich/poor identical to CT77
    
    desert = isDesert(_uwp);       
    asteroid = isAsteroid(_uwp);  
    
    if (_uwp.hydro == 10    ){ water = true; }
    if (_uwp.atmo == 0      ){ vacuum = true; }
    if (_uwp.atmo <= 1 &&
        _uwp.hydro >= 1     ){ icecapped = true; }
  }
  
  Boolean isDesert(UWP _uwp  ){ return _uwp.hydro == 0; }
  Boolean isAsteroid(UWP _uwp){ return _uwp.size == 0; }
  
  String toString(){
    String output = super.toString();
    if (water)          { output += "Wa "; }
    if (desert)         { output += "De "; }
    if (vacuum)         { output += "Va "; }
    if (asteroid)       { output += "As "; }
    if (icecapped)      { output += "Ic "; }
    return output;
  }
}

// Scouts p. 32
class TradeClass_ScoutsEx extends TradeClass_CT81 {
  TradeClass_ScoutsEx(UWP _uwp){ super(_uwp); }

  // agricultural/nonagricultural/industrial/nonindustrial/rich/poor identical to CT77
  // water/vacuum/icecapped identical to CT81

Boolean isDesert(UWP _uwp){ return (_uwp.hydro == 0 && _uwp.atmo >= 2); }
  
  Boolean isAsteroid(UWP _uwp){ 
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;
    return (uwp.size == 0 && !uwp.isPlanet); 
  }
}

// MTRM p. 25
//  table also includes Vargr & Aslan details, not implementing yet
class TradeClass_MT extends TradeClass_ScoutsEx {
  Boolean barren = false;
  Boolean fluid = false;
  Boolean highpop = false;
  Boolean lowpop = false;

  TradeClass_MT(UWP _uwp){
    super(_uwp);
    
    // agricultural/ice-capped/non-agricultural/poor/rich/vacuum/water identical to CT81
    // desert identical to Scouts

    // for industrial, RAW states atmo 2-4,7,9 / pop 9+ and the errata doesn't call it out
    // but this still looks incorrect
    // since CT77 this has been atmo 0-2,4,7,9 (vacuum or tainted)
    // this looks like a typo to me, so leaving it same as previous rules
    
    // Added in MegaTraveller:
    if (_uwp.pop == 0 && _uwp.gov == 0 && _uwp.law == 0){ barren = true; }
    if (_uwp.atmo >= 10 && _uwp.atmo <= 12 && _uwp.hydro >= 1){ fluid = true; }   // MegaTraveller errata p. 21: RAW is size A+ && atmo 1+. Corrected to atmo A-C && hydro 1+
    if (_uwp.pop >= 9){ highpop = true; }
    if (_uwp.pop >= 1 && _uwp.pop <= 3){ lowpop = true; }                         // MegaTraveller errata p. 25: RAW is pop 3-. Corrected to pop 1-3 (i.e. not Barren worlds)
    if (asteroid){ vacuum = false; }  // MTRM p.25 Step 12 notes: "However, an Asteroid Belt (As) is automatically a Vacuum World, and need not have the Va code." 
  }

  // MegaTraveller adds atmo 0 & hydro 0 to conditions - this is redundant, since
  // under these rules, a size 0 world is automatically atmo 0 / hydro 0
  // Also, they don't explicitly call out the Planet condition from Scouts but the same logic applies, so keeping it
  Boolean isAsteroid(UWP _uwp){ 
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;

    return (uwp.size == 0 &&  
            uwp.atmo == 0 &&
            uwp.hydro == 0 &&
            !uwp.isPlanet); 
  }

  // MegaTraveller errata p. 21 - Barren worlds (pop 0) are not counted as non-industrial or poor
  Boolean isNonindustrial(UWP _uwp){ return (_uwp.pop >= 1 && _uwp.pop <= 6); }
  Boolean isPoor(UWP _uwp){ return (_uwp.atmo >= 2 && _uwp.atmo <= 5 && _uwp.hydro <= 3 && _uwp.pop >= 1); }
 
  String toString(){
    String output = super.toString();
    if (barren)       { output += "Ba "; }
    if (fluid)        { output += "Fl "; }
    if (highpop)      { output += "Hi "; }
    if (lowpop)       { output += "Lo "; }
    return output;
  }
}