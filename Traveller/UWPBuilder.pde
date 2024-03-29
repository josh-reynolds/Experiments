// basic UWP Builder implements the CT77 rules from Book 3
class UWPBuilder {
  Dice roll;
  
  UWPBuilder(){
    roll = new Dice();
  }
  
  void newUWPFor(System _s){
    char starport = generateStarport();
    int size      = generateSize(); 
    int atmo      = generateAtmo(size);
    int hydro     = generateHydro(size, atmo);
    int pop       = generatePop();
    int gov       = generateGov(pop);
    int law       = generateLaw(gov, pop);
    int tech      = generateTech(starport, size, atmo, hydro, pop, gov); 

    _s.uwp = ruleset.newUWP(starport, size, atmo, hydro, pop, gov, law, tech);
  }
  
  char generateStarport(){ return traffic.getStarport(roll.two()); } 
  
  int generateSize(){ return roll.two(-2); }
  
  int generateAtmo(int _size){
    int result = roll.two(_size - 7);
    if (_size == 0 || result < 0){ result = 0; }
    return result;
  }
  
  int generateHydro(int _size, int _atmo){
    int result = roll.two(_size - 7);
    if (_atmo <= 1 || _atmo >= 10){ result -= 4; }
    if (_size <= 1 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }

  int generatePop(){ return roll.two(-2); }
  
  // CT77/CT81/Scouts only list Government types up to D (13),
  // though the die range could generate up to 15
  // MegaTraveller later introduces Government types E & F (14 + 15)
  // should we cap this value here?
  int generateGov(int _pop){
    int result = roll.two(_pop - 7);
    if (result < 0){ result = 0; }
    return result;
  }

  int generateLaw(int _gov, int _pop){    // pop not used until T5, adding here for the template interface
    int result = roll.two(_gov - 7);
    if (result < 0){ result = 0; }
    return result;
  }
  
  int techStarportModifier(char _starport){
    if (_starport == 'A'){ return 6; }
    if (_starport == 'B'){ return 4; }
    if (_starport == 'C'){ return 2; }
    if (_starport == 'X'){ return -4; }
    return 0;
  }
  
  int techSizeModifier(int _size){
    if (_size <= 1             ){ return 2; }
    if (_size > 1 && _size <= 4){ return 1; }
    return 0;
  }
  
  int techAtmoModifier(int _atmo){
    if (_atmo <= 3 || _atmo >= 10){ return 1; }
    return 0;
  }
  
  int techHydroModifier(int _hydro){
    if (_hydro == 9 ){ return 1; }
    if (_hydro == 10){ return 2; }
    return 0;
  }
  
  int techPopModifier(int _pop){
    if (_pop >= 1 && _pop <= 5){ return 1; }
    if (_pop == 9             ){ return 2; }
    if (_pop == 10            ){ return 4; }
    return 0;
  }
  
  int techGovModifier(int _gov){
    if (_gov == 0 || _gov == 5){ return 1; }
    if (_gov >= 13            ){ return -2; }
    return 0;
  }
  
  int generateTech(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov){
    int modifier = 0;
    modifier += techStarportModifier(_starport);    
    modifier += techSizeModifier(_size);
    modifier += techAtmoModifier(_atmo);
    modifier += techHydroModifier(_hydro);
    modifier += techPopModifier(_pop);
    modifier += techGovModifier(_gov);
    return roll.one(modifier);
  }  
}

// T4 follows the CT81 procedure, including the version of generateHydro() below (T4 pp. 129-135)
class UWPBuilder_CT81 extends UWPBuilder {
  UWPBuilder_CT81(){ }
  // starport identical to CT77
  // size identical to CT77
  // atmo identical to CT77
  // hydro slightly different - see override below
  // pop identical to CT77
  // gov identical to CT77
  // law identical to CT77
  // tech identical to CT77
  
  // size 1 worlds are no longer forced to 0 hydro
  // discrepancy between text (p. 7) and summary table (p. 12):
  //  - table is identical to CT77 (other than change above)
  //  - text adds ATMO instead of SIZE; using that here
  int generateHydro(int _size, int _atmo){
    int result    = roll.two(_atmo - 7);
    if (_atmo <= 1 || _atmo >= 10){ result -= 4; }
    if (_size == 0 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }  
}

// T5 close to the CT81 procedure:
//  it uses 'flux' (die - die) instead of 2d-7, but the output distribution is the same, so leaving that alone
//  Starport - identical to CT81/CT77, generated via 'Standard' setting in SubsectorTraffic
//  Size - allows for 'exploding' results beyond size 10 (reroll as 1D+9 if first roll is a 10)
//  Atmo - capped at F (15), otherwise identical
//  Hydro - text on p. 432 states size mod, but table on p. 433 states atmo mod - using latter
//   also pushes Size 2 and below to Hydro 0
//  Pop - allows for 'exploding' results beyond size 10 (reroll as 1D+9 if first roll is a 10)
//  Gov - capped at F (15), and set to 0 if Pop 0
//  Law - capped at J (18), and set to 0 if Pop 0
//  Tech - mostly identical to CT81:
//    Starport mod includes type F Starport which doesn't apply for mainworld
//    Size mod identical
//    Atmo mod identical
//    Hydro mod identical
//    Pop mod identical
//    Gov mod identical
class UWPBuilder_T5 extends UWPBuilder_ScoutsEx {
  UWPBuilder_T5(){ }

  int generateSize(){ 
    int result = roll.two(-2);
    if (result == 10){ result = roll.one(9); }
    return result; 
  }
  
  int generateAtmo(int _size){
    int result = roll.two(_size - 7);
    if (_size == 0 || result < 0){ result = 0; }
    if (result > 15){ result = 15; }
    return result;
  }  

  int generateHydro(int _size, int _atmo){
    int result    = roll.two(_atmo - 7);
    if (_atmo <= 1 || _atmo >= 10){ result -= 4; }
    if (_size < 2 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }  

  int generatePop(){ 
    int result = roll.two(-2);
    if (result == 10){ result = roll.one(9); }
    return result;  
  }

  int generateGov(int _pop){
    if (_pop == 0){ return 0; }
    int result = roll.two(_pop - 7);
    if (result < 0){ result = 0; }
    if (result > 15){ result = 15; }
    return result;
  }

  int generateLaw(int _gov, int _pop){  
    if (_pop == 0){ return 0; }
    int result = roll.two(_gov - 7);
    if (result < 0){ result = 0; }
    if (result > 18){ result = 18; }
    return result;
  }
}

class UWPBuilder_ScoutsEx extends UWPBuilder {
  UWPBuilder_ScoutsEx(){ super(); }
  
  // Slightly unusual calling convention to avoid duplicate methods:
  //   most Habitable Orbits do not have a size before requesting a UWP, so _size is null
  //   but Moons already have size established and call this method with an int value
  //   (and using Integer instead of int to allow null values)
  void newUWPFor(Orbit _o, Integer _size){
    if (debug == 2){ println("** UWPBuilder.newUWPFor(" + _o.getClass() + ", " + _size + ")"); }
    
    int size;
    if (_size == null){
      size = generateSizeFor(_o);
    } else {
      size = _size;
    }
    if (size <= 0){ size = 0; }   // preserving from old ctor - need to review if this can actually come in as negative value
                                  // Yes. This is part of satellite generation - size 0 is a Ring, size negative is an 'S' world.
                                  
    int atmo = generateAtmoFor(_o, size);
    int hydro = generateHydroFor(_o, size, atmo);
    int pop = generatePopFor(_o, size, atmo);
    
    // temporary values - will be populated once mainworld is established
    char starport = 'X';
    int gov       = 0;
    int law       = 0;
    int tech      = 0;
    
    ((Habitable)_o).setUWP(ruleset.newUWP(_o, starport, size, atmo, hydro, pop, gov, law, tech));
  }
  
  void completeUWPFor(Habitable _h, UWP _uwp){ 
    if (_h.isMainworld()){                // for mainworld, gov/law/starport/tech identical to CT77
      _uwp.gov      = generateGov(_uwp.pop);
      _uwp.law      = generateLaw(_uwp.gov, _uwp.pop);
      _uwp.starport = generateStarport();
      _uwp.tech     = generateTech(_uwp.starport, _uwp.size, _uwp.atmo, _uwp.hydro, _uwp.pop, _uwp.gov);
    } else {
    //  // need backreference to mainworld for the system - Scouts pp. 33 + 38
    //  //  * subordinate government = 1D, +2 if mainworld gov 7+, 6 if mainworld gov 6; = 0 if pop = 0
    //  //  * subordinate law = 1D-3 + mainworld law; = 0 if gov = 0
    //  //  * 'note subordinate facilities'
    //  //  * subordinate tech level = mainworld tech - 1; = mainworld tech if research lab / military facility
    //  //  * spaceport type from table, modified by local pop

      System sys;                                // TO_DO: find a better way to plumb this value through, this is kinda ugly
      Orbit o = (Orbit)_h;
      if (o.barycenter.isStar()){
        sys = ((Star)o.barycenter).parent;
      } else {
        sys = ((Star)o.barycenter.barycenter).parent;
      }
      
      // problem: mainworld is null at this point, not set until the call chain that calls this one completes
      // (Planet(oid).completeUWP() called from Star.designateMainworld()
      // really need to separate and finish the mainworld first, then loop through remainder
      // (in addition to null reference, the final gov/law/etc. fields on the mainworld are needed in this block
      //   put a hack in place upstream in Star.designateMainworld(), will need reworking
      
      Habitable main = ((System_ScoutsEx)sys).mainworld;
      UWP mainUWP = main.getUWP();
      
      _uwp.gov      = generateSubordinateGov(mainUWP.gov, _uwp.pop);
      _uwp.law      = generateSubordinateLaw(mainUWP.law, _uwp.gov);
      _uwp.starport = generateSubordinateStarport(_uwp.pop);     // actually a SPACEport per RAW, but we're sharing a field name w/ mainworlds...
      _uwp.tech     = generateSubordinateTech(mainUWP.tech);     // will be adjusted later after facilities are generated
    }
  }
  
  int generateSizeFor(Orbit _o){
    if (debug == 2){ println("**** UWPBuilder.generateSizeFor(Orbit) for " + this.getClass()); }  
    if (_o.isPlanetoid()){ return 0; }

    // MegaTraveller/T:NE follow the same modifiers (MTRM p. 28, T:NE p. 194)
    int modifier = 0;
    if (_o.getOrbitNumber() == 0  ){ modifier -= 5; }
    if (_o.getOrbitNumber() == 1  ){ modifier -= 4; }
    if (_o.getOrbitNumber() == 2  ){ modifier -= 2; }
    if (_o.isOrbitingClassM()){ modifier -= 2; }
    int result = roll.two(modifier - 2);  
    
    if (result <= 0){ result = 0; }

    return result;
  }
  
  int generateAtmoFor(Orbit _o, int _size){
    if (debug == 2){ println("**** UWPBuilder_ScoutsEx.generateAtmo() for " + _o.getClass()); }
    
    // MegaTraveller/T:NE follow the same procedure (MTRM p. 28, T:NE p. 194,195)
    int modifier = 0;
    if (_o.isInnerZone()){ 
      if (_o.isMoon()){    // Scouts p.33 + p.37 - Moons are _almost_ identical for Atmo determination
        modifier -= 4;
      } else {
        modifier -= 2;
      }
    }
    if (_o.isOuterZone()){ modifier -= 4; }
    
    int result = roll.two(_size + modifier - 7);

    Boolean farOuter = false;
    if (_o.isMoon()){
      farOuter = _o.barycenter.isAtLeastTwoBeyondHabitable();
    } else {
      farOuter = _o.isAtLeastTwoBeyondHabitable();
    }
    if (farOuter && roll.two() == 12){ result = 10; }

    if (_size == 0 || result < 0){ result = 0; }        // includes size 'S' (numerically zero)
    if (_size <= 1 && _o.isMoon()){ result = 0; }   // see note above          
          
    return result;  
  }
  
  int generateHydroFor(Orbit _o, int _size, int _atmo){
    if (debug == 2){ println("**** UWPBuilder_ScoutsEx.generateHydro() for " + _o.getClass()); }

    if (_o.isInnerZone()          ){ return 0; }
    if (_size == 0                ){ return 0; }       // includes size 'S' (numerically zero)
    if (_size == 1 && !_o.isMoon()){ return 0; }       // Scouts p.33 + p.37 - as with atmo, Moons are _almost_ identical
    
    int modifier = 0;
    if (_o.isOuterZone()){
      if (_o.isMoon()){                               // see note above
        modifier -= 4;
      } else {
        modifier -= 2;
      }
    }
    if (_atmo <= 1 || _atmo >= 10){ modifier -= 4; }
     
    int result = roll.two(_size + modifier - 7);
    result = constrain(result, 0, 10);    
    
    return result;  
  }
  
  int generatePopFor(Orbit _o, int _size, int _atmo){    
    if (debug == 2){ println("**** UWP_ScoutsEx.generatePop() for " + this.getClass()); }
    
    if (_o.isRing()){ return 0; }
    
    int modifier = 0;
    if (_o.isInnerZone()     ){ modifier -= 5; }
    if (_o.isOuterZone()     ){
      if (_o.isMoon()){                               // Scouts p.33 + p.37 - as with atmo, Moons are _almost_ identical
        modifier -= 4;
      } else {
        modifier -= 3;
      } 
    }
    if (!(_atmo == 0 || _atmo == 5 ||
          _atmo == 6 || _atmo == 8)   ){ modifier -= 2; }
    if (_o.isMoon() && _atmo == 0){ modifier -= 2; }   // see note above
    
    if (_o.isMoon() && _size <= 4){ modifier -= 2; }   // see note above
     
    int result = roll.two(modifier - 2);
    if (result < 0){ result = 0; }
    
    return result;
  }
  
  int generateSubordinateGov(int _mainworldGov, int _pop){
    //  * subordinate government = 1D, +2 if mainworld gov 7+, 6 if mainworld gov 6; = 0 if pop = 0
    
    if (_pop == 0         ){ return 0; }
    if (_mainworldGov == 6){ return 6; }
    
    int dieThrow = roll.one();
    if (_mainworldGov >= 7){ dieThrow += 2; }
    
    if (dieThrow < 5){
      return dieThrow - 1;
    } else {
      return 6;
    }
  }
  
  // MegaTraveller follows the same procedure (MTRM p. 29)
  // New Era follows the same procedure (T:NE p. 195)
  int generateSubordinateLaw(int _mainworldLaw, int _gov){
    //  * subordinate law = 1D-3 + mainworld law; = 0 if gov = 0
    if (_gov == 0          ){ return 0; }
    return roll.one(_mainworldLaw - 3);
  }
  
  // MegaTraveller follows the same procedure (MTRM p. 29)
  // New Era follows the same procedure (T:NE p. 195)
  char generateSubordinateStarport(int _pop){
    int modifier = 0;
    if (_pop >= 6){ modifier += 2; }
    if (_pop == 1){ modifier -= 2; }
    if (_pop == 0){ modifier -= 3; }    // text on p. 39 only has the previous two; this one is w/ the table on p. 29
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
  
  // T:NE follows the same procedure (T:NE p. 195)
  int generateSubordinateTech(int _mainworldTech){
    //  * subordinate tech level = mainworld tech - 1; = mainworld tech if research lab / military facility
    // this value is adjusted once subordinate facilities have been created
    
    return _mainworldTech - 1;
  }
}

class UWPBuilder_MT extends UWPBuilder_ScoutsEx {
  UWPBuilder_MT(){ super(); }

  // Atmo procedure is identical to Scouts (MTRM p. 28)
  
  // T:NE duplicates this procedure, but note it carries RAW, not the errata version
  //  I'm going to assume the errata should apply and not override for T:NE (p. 194,195)
  int generateHydroFor(Orbit _o, int _size, int _atmo){  
    if (debug == 2){ println("**** UWPBuilder_MT.generateHydro() for " + _o.getClass()); }

    if (_o.isInnerZone()){ return 0; }    
    if (_size == 0      ){ return 0; }  // includes size 'S' (numerically zero)
                                        // changed from Scouts - size 1 planets not longer have 0 hydrographics automatically
    
    int modifier = 0;
    if (_o.isOuterZone()){
      if (_o.isMoon()){
        modifier -= 4;
      } else {
        modifier -= 2;
      }
    }
    if (_atmo <= 1 || _atmo >= 10){    // Changed from Scouts - modifier is -2 for Planets, -4 for Moons (MTRM p.28,29) 
      if (_o.isMoon()){
        modifier -= 4;
      } else {
        modifier -= 2;
      } 
    }
     
    int result = roll.two(_atmo + modifier - 7);     // MTRM errata p. 22 - modifier should be atmo, not size, like CT81
    result = constrain(result, 0, 10);    
    
    return result;    
  }
  
  // MT removes the atmospheric modifiers for population on Planets, and modifies those for Moons (MTRM p. 28, 29)
  // T:NE follows the same procedure (T:NE p. 194), adds supplemental note that 'maximum population = Mainworld - 1'
  int generatePopFor(Orbit _o, int _size, int _atmo){
    if (debug == 2){ println("**** UWP_MT.generatePop() for " + this.getClass()); }
    
    if (_o.isRing()){ return 0; }
    
    int modifier = 0;
    if (_o.isInnerZone()     ){ modifier -= 5; }
    if (_o.isOuterZone()     ){
      if (_o.isMoon()){                               // MTRM p.29
        modifier -= 4;
      } else {
        modifier -= 3;
      } 
    }
    if (_o.isMoon() && _size <= 4){ modifier -= 2; }
    if (_o.isMoon() && 
        !(_atmo == 5 || _atmo == 6 || _atmo == 8)){ modifier -= 2; } // under Scouts, this applied to Planets - in MT, it is just Moons (MTRM p. 29)

     
    int result = roll.two(modifier - 2);
    if (result < 0){ result = 0; }
    
    return result;
  } 

  // MegaTraveller RAW matches CT77/CT81/Scouts for Tech Level generation, but the errata introduces some changes
  // MegaTraveller errata p. 21 mentions a missing modifier for 'Starport F', but those are not possible
  //  for mainworlds, which are the only planets this method applies to  - omitting this change
  // MegaTraveller errata p. 21 extends to Governments E & F (14 + 15)
  int techGovModifier(int _gov){
    if (_gov == 0 || _gov == 5){ return 1; }
    if (_gov == 13            ){ return -2; }
    if (_gov >= 14            ){ return -1; }
    return 0;
  }   
  
  // MT changes the procedure slightly from Scouts (MTRM p. 29)
  // New Era uses the same procedure (T:NE p. 195)
  int generateSubordinateGov(int _mainworldGov, int _pop){
    if (_pop == 0         ){ return 0; }
    
    int modifier = 0;
    if (_mainworldGov == 6){ modifier += _pop; }
    if (_mainworldGov >= 7){ modifier -= 1; }
    
    int dieThrow = roll.one(modifier);
    
    if (dieThrow < 5){
      return dieThrow - 1;
    } else {
      return 6;
    }
  }
}