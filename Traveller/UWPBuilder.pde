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
    int law       = generateLaw(gov);
    int tech      = generateTech(starport, size, atmo, hydro, pop, gov); 

    _s.uwp = new UWP(starport, size, atmo, hydro, pop, gov, law, tech);
  }
  
  // see comments above - this probably gets pushed down into the "for Orbits" leg of this hierarchy
  //void completeUWPFor(Habitable _h, UWP _uwp){
  //  println("In UWPBuilder.completeUWP()");
    
  //  // from UWP_ScoutsEx.completeUWP(): 
  //  if (_h.isMainworld()){                // for mainworld, gov/law/starport/tech identical to CT77
  //    _uwp.gov      = generateGov(_uwp.pop);
  //    _uwp.law      = generateLaw(_uwp.gov);
  //    _uwp.starport = generateStarport();
  //    _uwp.tech     = generateTech(_uwp.starport, _uwp.size, _uwp.atmo, _uwp.hydro, _uwp.pop, _uwp.gov);
  //  } else {
  //  //  // need backreference to mainworld for the system - Scouts pp. 33 + 38
  //  //  //  * subordinate government = 1D, +2 if mainworld gov 7+, 6 if mainworld gov 6; = 0 if pop = 0
  //  //  //  * subordinate law = 1D-3 + mainworld law; = 0 if gov = 0
  //  //  //  * 'note subordinate facilities'
  //  //  //  * subordinate tech level = mainworld tech - 1; = mainworld tech if research lab / military facility
  //  //  //  * spaceport type from table, modified by local pop

  //  //  System sys;                                // TO_DO: find a better way to plumb this value through, this is kinda ugly
  //  //  if (planet.barycenter.isStar()){
  //  //    sys = ((Star)planet.barycenter).parent;
  //  //  } else {
  //  //    sys = ((Star)planet.barycenter.barycenter).parent;
  //  //  }
      
  //  //  // problem: mainworld is null at this point, not set until the call chain that calls this one completes
  //  //  // (Planet(oid).completeUWP() called from Star.designateMainworld()
  //  //  // really need to separate and finish the mainworld first, then loop through remainder
  //  //  // (in addition to null reference, the final gov/law/etc. fields on the mainworld are needed in this block
  //  //  //   put a hack in place upstream in Star.designateMainworld(), will need reworking
      
  //  //  Habitable main = ((System_ScoutsEx)sys).mainworld;
  //  //  UWP mainUWP = main.getUWP();
      
  //  //  gov      = generateSubordinateGov(mainUWP.gov);
  //  //  law      = generateSubordinateLaw(mainUWP.law);
  //  //  starport = generateSubordinateStarport();           // actually a SPACEport per RAW, but we're sharing a field name w/ mainworlds...
  //  //  tech     = generateSubordinateTech(mainUWP.tech);   // will be adjusted later after facilities are generated
  //  }
  //}
  
  // TO_DO: MegaTraveller introduces subsector travel classifications that modify this procedure (MTRM p.24)
  //  the distribution listed below is 'Standard'
  //  could probably handle this via several static arrays, also need to plumb into subsector properties
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
    
  int generateSizeFor(Orbit _o){
    if (debug == 2){ println("**** UWPBuilder.generateSizeFor(Orbit) for " + this.getClass()); }  
    if (_o.isPlanetoid()){ return 0; }

    // MegaTraveller follows the same modifiers (MTRM p. 28)
    int modifier = 0;
    if (_o.getOrbitNumber() == 0  ){ modifier -= 5; }
    if (_o.getOrbitNumber() == 1  ){ modifier -= 4; }
    if (_o.getOrbitNumber() == 2  ){ modifier -= 2; }
    if (_o.isOrbitingClassM()){ modifier -= 2; }
    int result = roll.two(modifier - 2);  
    
    if (result <= 0){ result = 0; }

    return result;
  }
  
  int generateAtmo(int _size){
    int result = roll.two(_size - 7);
    if (_size == 0 || result < 0){ result = 0; }
    return result;
  }
  
  // don't like this - dummy method in the parent to allow overrides
  int generateAtmoFor(Orbit _o, int _size){ return 0; }
  
  int generateHydro(int _size, int _atmo){
    int result = roll.two(_size - 7);
    if (_atmo <= 1 || _atmo >= 10){ result -= 4; }
    if (_size <= 1 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }

  // see comments above generateAtmoFor(Orbit)
  int generateHydroFor(Orbit _o, int _size, int _atmo){ return 0; }

  int generatePop(){ return roll.two(-2); }

  // see comments above generateAtmoFor(Orbit)
  int generatePopFor(Orbit _o, int _size, int _atmo){ return 0; }
  
  int generateGov(int _pop){
    int result = roll.two(_pop - 7);
    if (result < 0){ result = 0; }
    return result;
  }

  int generateLaw(int _gov){
    int result = roll.two(_gov - 7);
    if (result < 0){ result = 0; }
    return result;
  }
  
  // MegaTraveller uses the same procedure
  int generateTech(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov){
    int modifier = 0;
    
    if (_starport == 'A'){ modifier += 6; }
    if (_starport == 'B'){ modifier += 4; }
    if (_starport == 'C'){ modifier += 2; }
    if (_starport == 'X'){ modifier -= 4; }
    
    if (_size <= 1){              modifier += 2; }
    if (_size > 1 && _size <= 4){ modifier += 1; }
    
    if (_atmo <= 3 || _atmo >= 10){ modifier += 1; }
    
    if (_hydro == 9){  modifier += 1; }
    if (_hydro == 10){ modifier += 2; }
    
    if (_pop >= 1 && _pop <= 5){ modifier += 1; }
    if (_pop == 9){              modifier += 2; }
    if (_pop == 10){             modifier += 4; }
    
    if (_gov == 0 || _gov == 5){ modifier += 1; }
    if (_gov == 13){             modifier -= 2; }
    
    return roll.one(modifier);
  }  
}

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

class UWPBuilder_ScoutsEx extends UWPBuilder {
  UWPBuilder_ScoutsEx(){ super(); }

  // review why we're avoiding polymorphism - not sure the argument holds water
  //  we ran into inheritance issues through super ctor calls in the UWP class hierarchy
  //   trying to avoid that here
  //  but the Builder ctor is very simple, shouldn't have the same problems here
  //  and this parallel structure is getting ugly already (see comments on generateAtmoFor(Orbit) below)
  //  going to keep pushing a bit, but pretty sure we shift all this down
  
  // the difference between these two legs is the target/parent object:
  //  - "simple" rulesets attach the UWP to the System
  //  - more complex rulesets have multiple Orbits per System, each with a UWP
  // what if the target was a field on this class populated in the ctor?
  // then we could unify the signatures of the newUWPFor(x) methods and use them polymorphically in clients 
  void newUWPFor(Orbit _o){
    if (debug == 2){ println("** UWPBuilder.newUWPFor(" + _o.getClass() + ")"); }
    
    int size = generateSizeFor(_o);
    int atmo = generateAtmoFor(_o, size);
    int hydro = generateHydroFor(_o, size, atmo);
    int pop = generatePopFor(_o, size, atmo);
    
    // temporary values - will be populated once mainworld is established
    char starport = 'X';
    int gov       = 0;
    int law       = 0;
    int tech      = 0;
    
    println(str(starport) + str(size) + str(atmo) + str(hydro) + str(pop) + str(gov) + str(law) + "-" + str(tech));
    ((Habitable)_o).setUWP(new UWP_ScoutsEx(_o, starport, size, atmo, hydro, pop, gov, law, tech));
  }
  
  // Moons have size established before UWP is generated, so need an alternate ctor
  // should be opportunities to refactor common code with newUWPFor(Habitable)
  void newUWPFor(Orbit _o, int _size){
    if (debug == 2){ println("** UWPBuilder.newUWPFor(" + _o.getClass() + ", " + _size + ")"); }
    int size = _size;
    if (size <= 0){ size = 0; }   // preserving from old ctor - need to review if this can actually come in as negative value
    
    int atmo = generateAtmoFor(_o, size);
    int hydro = generateHydroFor(_o, size, atmo);
    int pop = generatePopFor(_o, size, atmo);
    
    // temporary values - will be populated once mainworld is established
    char starport = 'X';
    int gov       = 0;
    int law       = 0;
    int tech      = 0;
    
    println(str(starport) + str(size) + str(atmo) + str(hydro) + str(pop) + str(gov) + str(law) + "-" + str(tech));
    ((Habitable)_o).setUWP(new UWP_ScoutsEx(_o, starport, size, atmo, hydro, pop, gov, law, tech));
  }
  
  // see comments above - this probably gets pushed down into the "for Orbits" leg of this hierarchy
  void completeUWPFor(Habitable _h, UWP _uwp){
    println("In UWPBuilder.completeUWP()");
    
    // from UWP_ScoutsEx.completeUWP(): 
    if (_h.isMainworld()){                // for mainworld, gov/law/starport/tech identical to CT77
      _uwp.gov      = generateGov(_uwp.pop);
      _uwp.law      = generateLaw(_uwp.gov);
      _uwp.starport = generateStarport();
      _uwp.tech     = generateTech(_uwp.starport, _uwp.size, _uwp.atmo, _uwp.hydro, _uwp.pop, _uwp.gov);
    } else {
    //  // need backreference to mainworld for the system - Scouts pp. 33 + 38
    //  //  * subordinate government = 1D, +2 if mainworld gov 7+, 6 if mainworld gov 6; = 0 if pop = 0
    //  //  * subordinate law = 1D-3 + mainworld law; = 0 if gov = 0
    //  //  * 'note subordinate facilities'
    //  //  * subordinate tech level = mainworld tech - 1; = mainworld tech if research lab / military facility
    //  //  * spaceport type from table, modified by local pop

    //  System sys;                                // TO_DO: find a better way to plumb this value through, this is kinda ugly
    //  if (planet.barycenter.isStar()){
    //    sys = ((Star)planet.barycenter).parent;
    //  } else {
    //    sys = ((Star)planet.barycenter.barycenter).parent;
    //  }
      
    //  // problem: mainworld is null at this point, not set until the call chain that calls this one completes
    //  // (Planet(oid).completeUWP() called from Star.designateMainworld()
    //  // really need to separate and finish the mainworld first, then loop through remainder
    //  // (in addition to null reference, the final gov/law/etc. fields on the mainworld are needed in this block
    //  //   put a hack in place upstream in Star.designateMainworld(), will need reworking
      
    //  Habitable main = ((System_ScoutsEx)sys).mainworld;
    //  UWP mainUWP = main.getUWP();
      
    //  gov      = generateSubordinateGov(mainUWP.gov);
    //  law      = generateSubordinateLaw(mainUWP.law);
    //  starport = generateSubordinateStarport();           // actually a SPACEport per RAW, but we're sharing a field name w/ mainworlds...
    //  tech     = generateSubordinateTech(mainUWP.tech);   // will be adjusted later after facilities are generated
    }
  }
  
  int generateAtmoFor(Orbit _o, int _size){   // tricky - with the new parameter, this is no longer an override...
    println("@@@ UWPBuilder_ScoutsEx.generateAtmoFor()");

    if (debug == 2){ println("**** UWPBuilder_ScoutsEx.generateAtmo() for " + _o.getClass()); }
    
    // MegaTraveller follows the same procedure (MTRM p. 28)
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
    println("@@@ UWPBuilder_ScoutsEx.generateHydroFor()");   
    
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
    println("@@@ UWPBuilder_ScoutsEx.generatePopFor()");
    
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
}

class UWPBuilder_MT extends UWPBuilder_ScoutsEx {
  UWPBuilder_MT(){ super(); }

  // Atmo procedure is identical to Scouts (MTRM p. 28)
  
  int generateHydroFor(Orbit _o, int _size, int _atmo){
    println("@@@ UWPBuilder_MT.generateHydroFor()");   
    
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
     
    int result = roll.two(_size + modifier - 7);
    result = constrain(result, 0, 10);    
    
    return result;    
  }
  
  // MT removes the atmospheric modifiers for population on Planets, and modifies those for Moons (MTRM p. 28, 29)
  int generatePopFor(Orbit _o, int _size, int _atmo){
    println("@@@ UWPBuilder_MT.generatePopFor()");
    
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
  
  
}