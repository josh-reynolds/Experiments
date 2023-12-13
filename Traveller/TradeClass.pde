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
        
    nonagricultural = isNonagricultural(_uwp);
    industrial = isIndustrial(_uwp);
    nonindustrial = isNonindustrial(_uwp);
    rich = isRich(_uwp);        
    poor = isPoor(_uwp);
  }
  
  // to allow overrides - eventually all of these probably should be turned into methods
  Boolean isNonindustrial(UWP _uwp){ return _uwp.pop <= 6; }
  Boolean isPoor(UWP _uwp){ return (_uwp.atmo >= 2 && _uwp.atmo <= 5 && _uwp.hydro <= 3); }   

  Boolean isNonagricultural(UWP _uwp){
    return (_uwp.atmo  <= 3 &&
            _uwp.hydro <= 3 &&
            _uwp.pop   >= 6);
  }
  
  Boolean isIndustrial(UWP _uwp){
    return ((_uwp.atmo <= 2 || _uwp.atmo == 4 || _uwp.atmo == 7 || _uwp.atmo == 9) &&
            _uwp.pop >= 9);
  }

  Boolean isRich(UWP _uwp){
    return (_uwp.gov >= 4 && _uwp.gov <= 9 &&
           (_uwp.atmo == 6 || _uwp.atmo == 8) &&
            _uwp.pop >= 6 && _uwp.pop <= 8);
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
  
  TradeClass_CT81(UWP _uwp, System _system){
    super(_uwp, _system);
    
    // agricultural/nonagricultural/industrial/nonindustrial/rich/poor identical to CT77
    
    desert = isDesert(_uwp);       
    asteroid = isAsteroid(_uwp);  
    water = isWater(_uwp);
    
    if (_uwp.atmo == 0      ){ vacuum = true; }
    if (_uwp.atmo <= 1 &&
        _uwp.hydro >= 1     ){ icecapped = true; }
  }
  
  Boolean isDesert(UWP _uwp  ){ return _uwp.hydro == 0; }  
  Boolean isAsteroid(UWP _uwp){ return _uwp.size == 0; }
  Boolean isWater(UWP _uwp   ){ return _uwp.hydro == 10; }
  
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

    highpop = isHighPop(_uwp);
    barren = isBarren(_uwp);
  }
  
  Boolean isDesert(UWP _uwp ){ return (_uwp.hydro == 0 && _uwp.atmo >= 2); } // identical to Scouts version
  Boolean isHighPop(UWP _uwp){ return (_uwp.pop >= 9 ); } // text (p. 132) sets this to 10+, but table on p. 135 shows 9+ as in MegaTraveller - using this version  
  Boolean isBarren(UWP _uwp ){ return (_uwp.pop == 0); } // only dependent on pop score, not gov/law as in MegaTraveller (T4 p. 132)
  
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
    barren = isBarren(_uwp);
    fluid = isFluid(_uwp);
    lowpop = isLowPop(_uwp);                         
    
    if (_uwp.pop >= 9){ highpop = true; }
    if (asteroid){ vacuum = false; }  // MTRM p.25 Step 12 notes: "However, an Asteroid Belt (As) is automatically a Vacuum World, and need not have the Va code." 
  }

  Boolean isBarren(UWP _uwp){
    return (_uwp.pop == 0 && 
            _uwp.gov == 0 && 
            _uwp.law == 0);
  }

  // from MegaTraveller errata p. 25: RAW is pop 3-. Corrected to pop 1-3 (i.e. not Barren worlds)
  Boolean isLowPop(UWP _uwp){
    return (_uwp.pop >= 1 && 
            _uwp.pop <= 3);
  }

  // from MegaTraveller errata p. 21: RAW is size A+ && atmo 1+. Corrected to atmo A-C && hydro 1+
  Boolean isFluid(UWP _uwp){
    return (_uwp.atmo >= 10 && 
            _uwp.atmo <= 12 && 
            _uwp.hydro >= 1);
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

// Trade Classes from T5 p. 434
class TradeClass_T5 extends TradeClass_T4 {
  Boolean fluid = false;
  Boolean garden = false;
  Boolean hellworld = false;
  Boolean ocean = false;  
  Boolean dieback = false;
  Boolean lowpop = false;
  Boolean prehigh = false;
  Boolean preag = false;
  Boolean preind = false;
  Boolean prerich = false;
  Boolean prison = false;
  Boolean penal = false;
  Boolean reserve = false;
  Boolean colony = false;  
  Boolean hot = false;
  Boolean cold = false;
  Boolean twilight = false;
  Boolean tropic = false;
  Boolean tundra = false;
  Boolean satellite = false;
  Boolean locked = false;
  Boolean forbidden = false;
  Boolean puzzle = false;
  Boolean dangerous = false;
  
  // TO_DO: Applies to non-mainworld, undecided what to do with these
  //  should Trade Classifications now apply per-planet?
  //  or is this a replacement for facilities?
  // farming
  // mining
  // frozen  - HZ+2 or more, not possible for mainworld
  
  // TO_DO: Referee fiat, undecided what to do with these
  //  on p. 434 they note: "Cp, Cs, Cx require Starport A."
  //  on p. 435 they note: "Important worlds are more likely to be Capitals of subsectors and sectors."
  // military rule
  // subsector capital
  // sector capital
  // capital
  // data repository
  // ancient site
  
  TradeClass_T5(UWP _uwp, System _system){
    super(_uwp, _system);
    
    fluid = isFluid(_uwp);
    garden = isGarden(_uwp);
    hellworld = isHellworld(_uwp);
    ocean = isOcean(_uwp);
    dieback = isDieback(_uwp);
    lowpop = isLowPop(_uwp);
    prehigh = isPreHigh(_uwp);
    preag = isPreAg(_uwp);
    preind = isPreInd(_uwp);
    prerich = isPreRich(_uwp);
    prison = isPrison(_uwp);
    penal = isPenal(_uwp);
    reserve = isReserve(_uwp);
    colony = isColony(_uwp);
    
    hot = isHot(_system);
    cold = isCold(_system);
    twilight = isTwilight(_system);
    tropic = isTropic(_system);
    tundra = isTundra(_system);
    satellite = isSatellite(_system);
    locked = isLocked(_system);
    forbidden = isForbidden(_system);
    puzzle = isPuzzle(_system);
    dangerous = isDangerous(_system);
  }

  Boolean isForbidden(System _system){
    return ((System_CT81)_system).travelZone.equals("Red");
  }

  Boolean isPuzzle(System _system){
    return ((System_CT81)_system).travelZone.equals("Amber") && 
           _system.uwp.pop >= 7 && 
           _system.uwp.pop <= 12;   // table on p. 434 caps this at 12, doesn't allow for ultra-high pop worlds
  }
  
  Boolean isDangerous(System _system){
    return ((System_CT81)_system).travelZone.equals("Amber") && 
           _system.uwp.pop <= 6; 
  }

  Boolean isHot(System _system){
    return ((System_T5)_system).mainworldHZVariance == -1;
  }
  
  Boolean isCold(System _system){
    return ((System_T5)_system).mainworldHZVariance == 1;
  }

  Boolean isTwilight(System _system){
    return (((Orbit)((System_ScoutsEx)_system).mainworld).orbitNumber <= 1);  // TO_DO: possible bug if evaluated against a Satellite... verify
  }

  Boolean isTropic(System _system){
    return ((_system.uwp.size >= 6 && _system.uwp.size <= 9) &&
            (_system.uwp.atmo >= 4 && _system.uwp.atmo <= 9) &&
            (_system.uwp.hydro >= 3 && _system.uwp.hydro <= 7) &&
            ((System_T5)_system).mainworldHZVariance == -1);
  }
  
  Boolean isTundra(System _system){
    return ((_system.uwp.size >= 6 && _system.uwp.size <= 9) &&
            (_system.uwp.atmo >= 4 && _system.uwp.atmo <= 9) &&
            (_system.uwp.hydro >= 3 && _system.uwp.hydro <= 7) &&
            ((System_T5)_system).mainworldHZVariance == 1);    
  }

  Boolean isSatellite(System _system){
    return (((Orbit)((System_ScoutsEx)_system).mainworld).isMoon()); 
  }

  Boolean isLocked(System _system){
    Orbit o = ((Orbit)((System_ScoutsEx)_system).mainworld); 
    return (o.isMoon() && o.orbitNumber <= 13 );  // close satellite - TO_DO: would be better to have a query or field than this magic number...
  }

  // T5 adds atmo/hydro 0, just like MT (p. 434), but not the isPlanet critereon
  //  as noted above this is redundant since size 0 worlds must have 
  //  atmo/hydro 0 by these rules (p. 433)
  Boolean isAsteroid(UWP _uwp){ 
    return (_uwp.size == 0 &&  
            _uwp.atmo == 0 &&
            _uwp.hydro == 0); 
  }  

  // T5 caps desert at atmo 9
  Boolean isDesert(UWP _uwp){ 
    return (_uwp.hydro == 0 && 
            _uwp.atmo >= 2 &&
            _uwp.atmo <= 9); 
  }

  // same definition as MT, but we aren't inheriting from here - refactoring opportunity
  Boolean isFluid(UWP _uwp){
    return (_uwp.atmo >= 10 && 
            _uwp.atmo <= 12 && 
            _uwp.hydro >= 1);
  }

  Boolean isGarden(UWP _uwp){
    return (_uwp.size  >= 6 && _uwp.size  <= 8 &&
            (_uwp.atmo == 5 || _uwp.atmo  == 6 || _uwp.atmo == 8) &&
            _uwp.hydro >= 5 && _uwp.hydro <= 7);
  }
  
  // Trade Class table caps this at size 12, but that omits ultra-large sizes (13+) - seems like an error to me
  //  but coding this as RAW for now...
  Boolean isHellworld(UWP _uwp){
    return (((_uwp.size >= 3 && _uwp.size <= 5) || (_uwp.size >= 9 && _uwp.size <= 12)) &&
            (_uwp.atmo == 2 || _uwp.atmo == 4 || _uwp.atmo == 7 || (_uwp.atmo >= 9 && _uwp.atmo <= 12)) &&
            _uwp.hydro <= 2);
  }

  // Trade Class table caps this at hydro 12, but that omits ultra-large values (13+) - seems like an error to me
  //  but coding this as RAW for now...
  Boolean isOcean(UWP _uwp){
    return (_uwp.size >= 10 && 
            _uwp.size <= 12 && 
            _uwp.hydro == 10);
  }

  Boolean isWater(UWP _uwp){
    return (_uwp.size >= 5 && 
            _uwp.size <= 9 && 
            _uwp.hydro == 10);
  }

  Boolean isDieback(UWP _uwp){
    return (_uwp.pop == 0 && 
            _uwp.gov == 0 && 
            _uwp.law == 0 && 
            _uwp.tech > 0); 
  }

  Boolean isBarren(UWP _uwp){
    return (_uwp.pop == 0 && 
            _uwp.gov == 0 && 
            _uwp.law == 0 && 
            _uwp.tech == 0 && 
            (_uwp.starport == 'E' || _uwp.starport == 'X')); 
  }

  // same definition as MT, but we aren't inheriting from here - refactoring opportunity
  Boolean isLowPop(UWP _uwp){
    return (_uwp.pop >= 1 && 
            _uwp.pop <= 3);
  }

  // excludes Barren and LowPop
  Boolean isNonindustrial(UWP _uwp){ 
    return (_uwp.pop >= 4 && _uwp.pop <= 6); 
  }
  
  Boolean isPreHigh(UWP _uwp){ 
    return (_uwp.pop == 8); 
  }
  
  // Trade Class table caps this at 12, but that omits ultra-high pop (13+) - seems like an error to me
  //  but coding this as RAW for now...
  Boolean isHighPop(UWP _uwp){
    return (_uwp.pop >= 9 && _uwp.pop <= 12);
  }

  Boolean isPreAg(UWP _uwp){
    return (_uwp.atmo  >= 4 && _uwp.atmo  <= 9 &&
            _uwp.hydro >= 4 && _uwp.hydro <= 8 &&
            (_uwp.pop  == 4 || _uwp.pop   == 8));
  }

  // Trade Class table caps this at 12, but that omits ultra-high pop (13+) - seems like an error to me
  //  but coding this as RAW for now...
  Boolean isNonagricultural(UWP _uwp){
    return (_uwp.atmo  <= 3 &&
            _uwp.hydro <= 3 &&
            (_uwp.pop  >= 6 && _uwp.pop <= 12));
  }

  Boolean isPreInd(UWP _uwp){
    return ((_uwp.atmo <= 2 || _uwp.atmo == 4 || _uwp.atmo == 7 || _uwp.atmo == 9) &&
            (_uwp.pop  == 7 || _uwp.pop  == 8));
  }  

  // Trade Class table caps this at 12, but that omits ultra-high pop (13+) - seems like an error to me
  //  but coding this as RAW for now...
  Boolean isIndustrial(UWP _uwp){
    return ((_uwp.atmo <= 2 || _uwp.atmo == 4 || _uwp.atmo == 7 || _uwp.atmo == 9) &&
            (_uwp.pop >= 9 && _uwp.pop <= 12));
  }  
  
  Boolean isPreRich(UWP _uwp){
    return ((_uwp.atmo == 6 || _uwp.atmo == 8) &&
            (_uwp.pop  == 5 || _uwp.pop  == 9));
  }

  // Gov has been dropped as a critereon for Rich
  Boolean isRich(UWP _uwp){
    return ((_uwp.atmo == 6 || _uwp.atmo == 8) &&
            _uwp.pop >= 6 && _uwp.pop <= 8);
  }
  
  Boolean isPrison(UWP _uwp){
    return ((_uwp.atmo == 2 || _uwp.atmo == 3 || _uwp.atmo == 10 || _uwp.atmo == 11) &&
            (_uwp.hydro >= 1 && _uwp.hydro <= 5) &&
            (_uwp.pop >= 3 && _uwp.pop <= 6) &&
            (_uwp.law >= 6 && _uwp.law <= 9));
  }

  Boolean isPenal(UWP _uwp){
    return (isPrison(_uwp) && _uwp.gov == 6);
  }  

  Boolean isReserve(UWP _uwp){
    return ((_uwp.pop >= 1 && _uwp.pop <= 4) &&
            _uwp.gov == 6 &&
            (_uwp.law == 4 || _uwp.law == 5));
  }  

  // TO_DO: From table footnote 1, p. 434:
  //  "A colony is Owned by another world. Note the owning world with O:nnnn (=hex of owning world). The
  //   Owner is the Most Important, Highest Population Highest TL world within 6 hexes."
  Boolean isColony(UWP _uwp){
    return ((_uwp.pop >= 5 && _uwp.pop <= 10) &&
            _uwp.gov == 6 &&
            (_uwp.law >= 0 && _uwp.law <= 3));
  }   
  
  String toString(){
    String output = super.toString();
    if (fluid)        { output += "Fl "; }
    if (garden)       { output += "Ga "; }
    if (hellworld)    { output += "He "; }
    if (ocean)        { output += "Oc "; }
    if (dieback)      { output += "Di "; }
    if (lowpop)       { output += "Lo "; }
    if (prehigh)      { output += "Ph "; }
    if (preag)        { output += "Pa "; }
    if (preind)       { output += "Pi "; }
    if (prerich)      { output += "Pr "; }
    if (prison)       { output += "Px "; }
    if (penal)        { output += "Pe "; }
    if (reserve)      { output += "Re "; }
    if (colony)       { output += "Cy "; }
    if (hot)          { output += "Ho "; }
    if (cold)         { output += "Co "; }
    if (twilight)     { output += "Tz "; }
    if (tropic)       { output += "Tr "; }
    if (tundra)       { output += "Tu "; }
    if (satellite)    { output += "Sa "; }
    if (locked)       { output += "Lk "; }
    if (forbidden)    { output += "Fo "; }
    if (puzzle)       { output += "Pz "; }
    if (dangerous)    { output += "Da "; }
    return output;
  }
}