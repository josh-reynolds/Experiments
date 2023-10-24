// CT77 Book 2 p. 43
class TradeClass {
  Boolean agricultural = false;
  Boolean nonagricultural = false;
  Boolean industrial = false;
  Boolean nonindustrial = false;
  Boolean rich = false;
  Boolean poor = false;

  System system;
  
  TradeClass(UWP _uwp, System _system){
    system = _system;
    
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
  
  TradeClass_CT81(UWP _uwp, System _system){
    super(_uwp, _system);
    
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

// T4 is almost identical to CT81, with minor exceptions (T4 p. 132, 135)
class TradeClass_T4 extends TradeClass_CT81 {
  Boolean highpop = false;
  Boolean barren = false;
  
  TradeClass_T4(UWP _uwp, System _system){
    super(_uwp, _system);

    if (_uwp.pop >= 9 ){ highpop = true; } // text (p. 132) sets this to 10+, but table on p. 135 shows 9+ as in MegaTraveller - using this version
    if (_uwp.pop == 0 ){ barren = true; }  // only dependent on pop score, not gov/law as in MegaTraveller (T4 p. 132)
  }
  
  Boolean isDesert(UWP _uwp  ){ return (_uwp.hydro == 0 && _uwp.atmo >= 2); } // identical to Scouts version
  
  String toString(){
    String output = super.toString();
    if (highpop) { output += "Hi "; }
    if (barren)  { output += "Ba "; }
    return output;
  }
}

// Scouts p. 32
class TradeClass_ScoutsEx extends TradeClass_CT81 {
  TradeClass_ScoutsEx(UWP _uwp, System _system){ super(_uwp, _system); }

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

  TradeClass_MT(UWP _uwp, System _system){
    super(_uwp, _system);

    // agricultural/ice-capped/non-agricultural/poor/rich/vacuum/water identical to CT81
    // desert identical to Scouts

    // for industrial, RAW states atmo 2-4,7,9 / pop 9+ and the errata doesn't call it out
    // but this still looks incorrect
    // since CT77 this has been atmo 0-2,4,7,9 (vacuum or tainted)
    // this looks like a typo to me, so leaving it same as previous rules
    // same potential typo repeated in T:NE (p. 187)
    
    // Added in MegaTraveller:
    if (isBarren(_uwp)){ barren = true; }
    if (_uwp.atmo >= 10 && _uwp.atmo <= 12 && _uwp.hydro >= 1){ fluid = true; }   // MegaTraveller errata p. 21: RAW is size A+ && atmo 1+. Corrected to atmo A-C && hydro 1+
    if (_uwp.pop >= 9){ highpop = true; }
    if (isLowPop(_uwp)){ lowpop = true; }                         // MegaTraveller errata p. 25: RAW is pop 3-. Corrected to pop 1-3 (i.e. not Barren worlds)
    if (asteroid){ vacuum = false; }  // MTRM p.25 Step 12 notes: "However, an Asteroid Belt (As) is automatically a Vacuum World, and need not have the Va code." 
  }

  Boolean isBarren(UWP _uwp){
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;

    return (uwp.pop == 0 && 
            uwp.gov == 0 && 
            uwp.law == 0);
  }

  Boolean isLowPop(UWP _uwp){
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;

    return (uwp.pop >= 1 && 
            uwp.pop <= 3);
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

class TradeClass_TNE extends TradeClass_MT {
  TradeClass_TNE(UWP _uwp, System _system){ super(_uwp, _system); }
    
  // TN:E adds a note: 'For Barren world, population multiplier must be 0. For Non-industrial, population multiplier must be 1+' (T:NE p. 187)
  Boolean isBarren(UWP _uwp){
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;

    return (uwp.pop == 0 && 
            uwp.gov == 0 && 
            uwp.law == 0 &&
            ((System_MT)system).populationMultiplier == 0);   
   }
   
   // New Era changes this to pop 4-, but neglects to screen out Barren (pop 0) (T:NE p. 187)
   //  I am adding a clause to check for population multiplier, as with isBarren()/isNonindustrial
   //  not RAW, but makes sense to me
   Boolean isLowPop(UWP _uwp){
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;

    return ((uwp.pop >= 1 && uwp.pop <= 4) ||
            (uwp.pop == 0 && ((System_MT)system).populationMultiplier > 0));
  }
  
  // TN:E adds a note: 'For Barren world, population multiplier must be 0. For Non-industrial, population multiplier must be 1+' (T:NE p. 187)
  Boolean isNonindustrial(UWP _uwp){ 
    UWP_ScoutsEx uwp = (UWP_ScoutsEx)_uwp;
    
    return ((uwp.pop >= 1 && uwp.pop <= 6) ||
            (uwp.pop == 0 && ((System_MT)system).populationMultiplier > 0)); 
  }
  
  // T:NE leaves out the MT errata concerning Poor worlds
}