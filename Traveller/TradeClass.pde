class TradeClass {
  Boolean agricultural = false;
  Boolean nonagricultural = false;
  Boolean industrial = false;
  Boolean nonindustrial = false;
  Boolean rich = false;
  Boolean poor = false;
  Boolean water = false;
  Boolean desert = false;
  Boolean vacuum = false;
  Boolean asteroid = false;
  Boolean icecapped = false;
  
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
        
    if (_uwp.hydro == 10){ water = true; }
    if (_uwp.hydro == 0) { desert = true; }
    if (_uwp.atmo == 0)  { vacuum = true; }
    if (_uwp.size == 0)  { asteroid = true; }
    if (_uwp.atmo <= 1 &&
        _uwp.hydro >= 1) { icecapped = true; }
  }
  
  String toString(){
    String output = "";
    if (agricultural)   { output += "Ag "; }
    if (nonagricultural){ output += "Na "; }
    if (industrial)     { output += "In "; }
    if (nonindustrial)  { output += "Ni "; }
    if (rich)           { output += "Ri "; }
    if (poor)           { output += "Po "; }
    if (water)          { output += "Wa "; }
    if (desert)         { output += "De "; }
    if (vacuum)         { output += "Va "; }
    if (asteroid)       { output += "As "; }
    if (icecapped)      { output += "Ic "; }
    return output;
  }
}