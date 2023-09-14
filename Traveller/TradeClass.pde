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
        
    if (_uwp.pop <= 6){ nonindustrial = true; }

    if (_uwp.gov >= 4 && _uwp.gov <= 9 &&
        (_uwp.atmo == 6 || _uwp.atmo == 8) &&
        _uwp.pop >= 6 && _uwp.pop <= 8){ rich = true; }        
        
    if (_uwp.atmo >= 2 && _uwp.atmo <= 5 &&
        _uwp.hydro <= 3){ poor = true; }
  }
  
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
  
  TradeClass_CT81(UWP _uwp){   // UWP fields should be uniform across hierarchy - no need to be specific
    super(_uwp);                    // and this causes issues for other UWP variants
    
    // agricultural/nonagricultural/industrial/nonindustrial/rich/poor identical to CT77
    
    desert = isDesert(_uwp);       // to allow overrides - eventually all of these probably should be turned into methods
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
    
    // agricultural/ice-capped/non-agricultural/non-industrial/poor/rich/vacuum/water identical to CT81

    // Changed from previous:
    // Asteroid        - size 0 / atmo 0 / hydro 0          (adds atmo + hydro, review)
    //  (automatically Va, doesn't need to have that one)
    // Desert          - atmo 2+ / hydro 0                  (adds atmo, review)    
    // Industrial      - atmo 2-4,7,9 / pop 9+              (changes atmo range, typo? check errata)
    
    // Added in MegaTraveller:
    if (_uwp.pop == 0 && _uwp.gov == 0 && _uwp.law == 0){ barren = true; }
    if (_uwp.size >= 10 && _uwp.atmo >= 1){ fluid = true; }
    if (_uwp.pop >= 9){ highpop = true; }
    if (_uwp.pop <= 3){ lowpop = true; }        
  }

  String toString(){
    String output = super.toString();
    if (barren)       { output += "Ba "; }
    if (fluid)        { output += "Fl "; }
    if (highpop)      { output += "Hi "; }
    if (lowpop)       { output += "Lo "; }
    return output;
  }
}