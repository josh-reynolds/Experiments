class StarBuilder {
  Dice roll;  

  StarBuilder(){
    roll = new Dice();
  }
  
  void newStar(System_ScoutsEx _parent){
    Star star = new Star(_parent);
    _parent.primary = star;
    
    createCompanionsFor(star);     // aren't companions just a special-case satellite? unify this and work with the composite structure
    createSatellitesFor(star);     // Star.createSatellites() is recursive on companion stars - need to handle this case
                                   // should there be something in createCompanions()? work this out later
    
    _parent.mainworld = designateMainworldFor(star);    // do we need assignment? I think the method sets the value directly...
  }

  void placeCapturedPlanetsFor(Star _star){
    println("Placing Captured Planets for " + _star);
    // ambiguity here - some of the notes from Empty Orbits (above) also applies - but:
    //  - by RAW, these are placed in orbit 2-12 +/- deviation
    //  - same biases as noted under Empty: 0 & 1 protected, bell curve around 7, nothing beyond 12
    //  - no notes for what to do if orbit is occupied
    
    if (roll.one() > 4){
      int quantity = floor(roll.one()/2);

      for (int i = 0; i < quantity; i++){
        float capturedOrbit = 0;
        int effectiveOrbit = 0;                     // chicken & egg w/ orbitalZones, may want to rethink how this passes to Orbit ctors
        
        Boolean assessingCandidates = true;
        while (assessingCandidates){                // potential infinite loop if there are no valid locations...
          capturedOrbit = generateCapturedOrbit();  // in practice would require an M or B giant star with a companion in orbit 11, extremely rare
          effectiveOrbit = round(capturedOrbit);
          if (_star.orbitIsForbidden(effectiveOrbit)){
            assessingCandidates = true;            
          } else {
            assessingCandidates = false;
          }
        }

        _star.addOrbit(capturedOrbit, new Planet(_star, effectiveOrbit, _star.orbitalZones[effectiveOrbit]));
        Planet captured = (Planet)_star.getOrbit(capturedOrbit);
        captured.setOrbitNumber(capturedOrbit);
      }
    }        
  }

  float generateCapturedOrbit(){
    int baseline = roll.two();
    int deviation = roll.two(-7);

    if (deviation == 0){      // RAW doesn't cover this scenario, but we should prevent captured planets in exact orbits
      if (roll.one() < 4){    // or they will potentially overwrite another entity 
        deviation = -1; 
      } else {
        deviation = 1;
      }
    }
    
    if (deviation < 0){
      baseline -= 1;
      deviation = 10 + deviation;
    }
    
    return baseline + (float)deviation/10;
  }

  // three cases:
  //  - DONE  orbit is inside star (have query method)
  //  - DONE  orbit is suppressed by nearby companion star
  //  -         TO_DO (Far companion case is unclear - in RAW, they don't have an orbit num so are not evaluated in this test)
  //  - DONE  orbit is too hot to allow planets
  void placeForbiddenOrbitsFor(Star _star, int _maxOrbit){
    println("Determining forbidden orbits for " + _star);
    for (int i = 0; i <= _maxOrbit; i++){
      if (_star.orbitIsForbidden(i) && _star.orbitIsNullOrEmpty(i)){
        _star.addOrbit(i, new Forbidden(_star, i, _star.orbitalZones[i]));
      }
    }
  }  
  
  // we have shifted to TreeMap, look for opportunities to simplify/eliminate this one
  void placeEmptyOrbitsFor(Star _star, int _maxOrbit){
    println("Determining empty orbits for " + _star);
    
    // Empty orbits per Scouts p.34 (table on p. 29)
    int modifier = 0;
    if (_star.type == 'B' || _star.type == 'A'){ modifier += 1; }
    if (roll.one(modifier) >= 5){
      int emptyCount = 0;
      switch(roll.one(modifier)){ 
        case 1:
        case 2:
          emptyCount = 1;
          break;
        case 3:
          emptyCount = 2;
          break;
        case 4:   // almost seems like a typo
        case 5:   // if a '4' roll returned 2, this would be a simple calculation
        case 6:   // notably, the captured planets column in same table is a simple oneDie()/2
        case 7:
          emptyCount = 3;
          break;
        default:
          emptyCount = 1;
          break;
      }
      
      for (int i = 0; i < emptyCount; i++){
        // By RAW, should roll twoDice() to find the empty orbit, but there are problems with that approach:
        //  - Will never choose orbits 0 or 1 (by design?)
        //  - Can generate more empty orbits than are available in the system
        //  - Bell curve bias towards orbits 6,7,8
        //  - Generates results outside existing orbits, needs lots of rerolls
        // I am going to implement a random picker that fixes the last two issues (flat curve, only existing orbits to choose from)
        //   and keep the protections for orbits 0 & 1 (maybe they wanted to ensure all systems have viable orbits?)
        int choice = getRandomUnassignedOrbitFor(_star, _maxOrbit);
        if (choice == -1){ if (debug >= 1){ println("No null available"); } break; } // don't much care for this 'magic value' - indicates no null orbits left
        if (debug >= 1){ println("Assigning " + choice + " to Empty"); }
        _star.addOrbit(choice, new Empty(_star, choice, _star.orbitalZones[choice]));
      }
    }
  }
  
  int calculateMaxOrbitsFor(Star _star){   
    int modifier = 0;
    if (_star.size == 2   ){ modifier += 8; }  // rules include Ia/Ib supergiants here, but no means to generate them - omitting
    if (_star.size == 3   ){ modifier += 4; }
    if (_star.type == 'M' ){ modifier -= 4; }
    if (_star.type == 'K' ){ modifier -= 2; }

    int result = roll.two(modifier); 
    if (result < 1){ 
      return 0; 
    } else {
      return result;
    }
  }
  
  void createSatellitesFor(Star _star){
    if (debug == 2){ println("Creating satellites for " + _star); }
        
    int orbitCount = calculateMaxOrbitsFor(_star);
    if (_star.isCompanion()){ orbitCount = constrain(orbitCount, 0, floor(_star.getOrbitNumber()/2)); }
    
    placeEmptyOrbitsFor(_star, orbitCount);
    placeForbiddenOrbitsFor(_star, orbitCount);
    placeCapturedPlanetsFor(_star);
    placeGasGiantsFor(_star, orbitCount);
    placePlanetoidBeltsFor(_star, orbitCount);
    placePlanetsFor(_star, orbitCount);
    
    ArrayList<Star> comps = _star.getCompanions();
    for (Star c : comps){
      createSatellitesFor(c);     // TO_DO: with the refactoring, we're not allowing for quaternary companions
    }                             // probably should rework how each member of the composite is created and 
                                  // re-order/shuffle these calls
                                  // see note above regarding companions - should rework to follow composite walk
                                  // will probably happen naturally as we turn our attention to the rest of Orbit hierarchy
                                  
    if (debug >= 1){ 
      println("Companions for " + this);
      printArray(_star.getCompanions());
    } 
  }
  
  void createCompanionsFor(Star _star){
    if (debug == 2){ println("Creating companions for " + _star); }
    int compCount = 0;
    if (_star.isPrimary() || _star.isFar()){
      compCount = generateCompanionCountFor(_star);
    }    
    if (debug >= 1){ println(compCount + " companions"); }

    for (int i = 0; i < compCount; i++){
      int orbitNum = generateCompanionOrbitFor(_star, i);
      
      Star companion = new Star(_star, orbitNum, _star.orbitalZones[orbitNum], _star.parent);

      if (orbitNum == 0 || companion.insideStar()){
        if (debug >= 1){ println("Companion in CLOSE orbit"); }        
        _star.closeCompanion = companion;        
      }

      _star.addOrbit(companion.getOrbitNumber(), companion);
    } 
  }
  
  // MegaTraveller uses the same odds for companion stars, with one adjustment  
  // TO_DO: MTRM p. 26: "Use DM -1 when returning to this table for a far companion."   
  int generateCompanionCountFor(Star _star){
    println("Determining companion count for " + _star);
    int dieThrow = roll.two();
    if (dieThrow < 8){ return 0; }
    if (dieThrow > 7 && dieThrow < 12){ return 1; }
    if (dieThrow == 12){ 
      if (_star.isPrimary()){ 
        return 2; 
      } else {
        return 1;
      }
    }
    return 0;
  }
  
  void placeGasGiantsFor(Star _star, int _maxOrbit){
    println("Placing Gas Giants for " + _star);
    if (roll.two() <= 9){
      switch(roll.two()){ 
        case 2:
        case 3:
          _star.gasGiantCount = 1;
          break;        
        case 4:
        case 5:
          _star.gasGiantCount = 2;
          break;        
        case 6:
        case 7:
          _star.gasGiantCount = 3;
          break;        
        case 8:
        case 9:
        case 10:
          _star.gasGiantCount = 4;        
          break;        
        case 11:
        case 12:
          _star.gasGiantCount = 5;        
          break;
        default:
          _star.gasGiantCount = 1;        
          break;
      }

      IntList availableOrbits = availableOrbitsForGiantsFor(_star, _maxOrbit);
      _star.gasGiantCount = min(_star.gasGiantCount, availableOrbits.size());
      if (debug >= 1){ println(_star.gasGiantCount + " Gas Giants in-system"); }  // need to consider at the System level, for Primary + all companions
      
      for (int i = 0; i < _star.gasGiantCount; i++){
        availableOrbits.shuffle();
        int index = availableOrbits.remove(0);
        _star.addOrbit(index, new GasGiant(_star, index, _star.orbitalZones[index]));
      }
    } else {
      if (debug >= 1){ println("No Gas Giants in-system"); }
    }
  }

  // will be very similar to GasGiants, above - duplication OK for now, but look for refactorings
  void placePlanetoidBeltsFor(Star _star, int _maxOrbit){
    println("Placing Planetoid Belts for " + _star);
    // uses # of Gas Giants as a modifier - rules don't specify, but I assume that means just for
    // the star which the potential planetoids orbit, not all companions
    int planetoidCount = 0;                      // not yet needed outside this method (MT and later include this count at System level, but IIRC Scouts does not)        
    if (roll.two(-_star.gasGiantCount) <= 6){
      switch(roll.two(-_star.gasGiantCount)){ 
        case -3:
        case -2:
        case -1:
        case 0:
          planetoidCount = 3;
          break;
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
          planetoidCount = 2;
          break;        
        default:
          planetoidCount = 1;        
          break;
      }
    
      IntList availableOrbits = availableOrbitsForPlanetoidsFor(_star, _maxOrbit);
      planetoidCount = min(planetoidCount, availableOrbits.size());
      if (debug >= 1){ println(planetoidCount + " Planetoid Belts in-system"); }
    
      // RAW p. 35: "If possible, planetoid belts should be placed in the next orbit inward from gas giants."
      IntList orbitsInwardFromGiants = new IntList();   // might want to refactor this out, do it inline for now
      for (int i = 0; i < availableOrbits.size(); i++){
        int index = availableOrbits.get(i); 
        if (index == _star.orbits.size()-1){ continue; }
        if (_star.getOrbit(index) != null && _star.getOrbit(index).isGasGiant()){
          orbitsInwardFromGiants.append(index);
          availableOrbits.remove(i);
        }
      }

      for (int i = 0; i < planetoidCount; i++){
        if (orbitsInwardFromGiants.size() > 0){
          orbitsInwardFromGiants.shuffle();
          int index = orbitsInwardFromGiants.remove(0);
          _star.addOrbit(index, new Planetoid(_star, index, _star.orbitalZones[index]));
          continue;
        }
        if (availableOrbits.size() > 0){
          availableOrbits.shuffle();
          int index = availableOrbits.remove(0);
          _star.addOrbit(index, new Planetoid(_star, index, _star.orbitalZones[index]));
        }
      }
    } else {
      if (debug >= 1){ println("No Planetoid Belts in-system"); }      
    }
  }

  void placePlanetsFor(Star _star, int _maxOrbit){
    println("Placing Planets for " + _star);
    for (int i = 0; i < _maxOrbit; i++){
      if (_star.orbitIsNull(i)){
        _star.addOrbit(i, new Planet(_star, i, _star.orbitalZones[i]));
      }
    }
  }

  // from tables on Scouts p.46
  // MegaTraveller follows the same procedure (MTRM p. 26)
  // Note: to ease handling, I am converting RAW "Close" + "Far" to equivalent orbit numbers
  int generateCompanionOrbitFor(Star _star, int _iteration){
    int modifier = 4 * (_iteration);
    if (_star.isCompanion()){ modifier -= 4; }
    if (debug >= 1){ println("Generating companion star orbit. Modifier: +" + modifier); }
    int dieThrow = roll.two(modifier);
    int result = 0;
    if (dieThrow < 4  ){ result = 0; }
    if (dieThrow == 4 ){ result = 1; }
    if (dieThrow == 5 ){ result = 2; }
    if (dieThrow == 6 ){ result = 3; }
    if (dieThrow == 7 ){ result = roll.one(4); }
    if (dieThrow == 8 ){ result = roll.one(5); }
    if (dieThrow == 9 ){ result = roll.one(6); }
    if (dieThrow == 10){ result = roll.one(7); }
    if (dieThrow == 11){ result = roll.one(8); }
    if (dieThrow >= 12){ 
      int distance = 1000 * roll.one();                           // distance in AU, converted to orbit number below
      if (distance == 1000                    ){ result = 14; }
      if (distance == 2000                    ){ result = 15; }
      if (distance == 3000 || distance == 4000){ result = 16; }
      if (distance >= 5000                    ){ result = 17; } 
    }
    
    return result;

    // TO_DO: need to handle two companions landing in same orbit
  }

  // replacement for getRandomNullOrbit() using TreeMap structure
  // flaws with this approach still exist and should be remedied later
  // TreeMap might give us some tools to simplify
  // TO_DO: this needs to be more robust
  int getRandomUnassignedOrbitFor(Star _star, int _maxOrbit){
    int counter = 0;               // probably need to be more thoughtful if there are none available, but using counter to escape infinite loop just in case
    while(counter < 100){
      int choice = floor(random(2, _maxOrbit));      // see notes in placeEmptyOrbits() - 0 & 1 are 'protected'  
      if (_maxOrbit <= 2){ break; }                  // but this fails in the case of very small systems, so need to bail out
      if (_star.getOrbit(choice) == null){ 
        return choice;
      }
      counter++;
    }
    return -1;  // and how would we handle this? will throw an exception when we use the value as an array index      
  }

  IntList availableOrbitsForGiantsFor(Star _star, int _maxOrbit){
    // per Scouts p. 34: "The number (of Gas Giants) may not exceed the number of available and non-empty orbits in the habitable and outer zones"
    IntList result = new IntList();
    for (int i = 0; i < _maxOrbit; i++){
      if (_star.orbitIsForbidden(i) || _star.orbitIsInnerZone(i)){ continue; }
      if (_star.orbitIsNull(i)){                       // should we also allow them to drop into Empty orbits? by RAW, no
        if (debug >= 1){ println("Orbit " + i + " qualifies"); }
        result.append(i);
      }
    }
    
    if (debug >= 1){ println("Found " + result.size() + " available orbits for Gas Giants"); }
    return result;
    
    // TO_DO: one (awkward) special case:
    //   " (i)f the table calls for a gas giant and there is no orbit available for it, create an orbit in the outer zone for it"
  }

  // probably refactoring opportunities w/ the similar Gas Giant method above - almost identical
  IntList availableOrbitsForPlanetoidsFor(Star _star, int _maxOrbit){
    IntList result = new IntList();
    for (int i = 0; i < _maxOrbit; i++){
      if (_star.orbitIsNull(i)){                                         // should we also allow them to drop into Empty orbits? by RAW, I think not
        if (debug >= 1){ println("Orbit " + i + " qualifies"); }         // though they never precisely define "available orbits"
        result.append(i);
      }
    }
    if (debug >= 1){ println("Found " + result.size() + " available orbits for Planetoids"); }   
    return result;
  }

  Habitable designateMainworldFor(Star _star){
    println("Finding mainworld");
    // Scouts p. 37: "The main world is the world in the system which has the greatest
    //  population. If more than one world has the same population, then select the world
    //  which is in the habitable zone, or failing that, which is closest to the central
    //  star. The main world need not be a planet; it can be a satellite or an asteroid
    //  belt, or a small world. It may not be a ring. The main world need not orbit the 
    //  central star in the system; it may be in orbit around the binary companion,
    //  or it may orbit a gas giant or other world."
    
    ArrayList<Habitable> candidates = _star.getAll(Habitable.class);
    
    // in some cases we can have a System with no Habitable orbits - need to insert one
    // to prevent NullPointerException downstream, and to comply with Traveller assumptions -
    // all systems can be represented by a UWP, which in terms here means 'has a Habitable'
    // RAW doesn't address this possibility, though it is possible there
    // simplest patch seems to be inserting a new Planet at the end of the orbits list
    if (candidates.size() == 0){
      println("No Habitables currently in-system - adding a new Planet");
      
      int newOrbit = _star.orbits.size();
      Boolean addingOrbit = true;
      while (addingOrbit){
        placeForbiddenOrbitsFor(_star, newOrbit);                   // need to test whether new orbit is valid
        if (_star.getOrbit(newOrbit) == null){
          addingOrbit = false;
        }
        newOrbit++;  
      }
      
      placePlanetsFor(_star, newOrbit);
      candidates = _star.getAll(Habitable.class);
    }

    if (debug == 2){ println("**** Habitables list length = " + candidates.size()); }
    if (debug == 2){ println("**** Orbits = " + _star.orbits); }
    
    int maxPop = -1;
    Habitable winner = null;
    for (Habitable h : candidates){
      if (h.getUWP().pop > maxPop){
        maxPop = h.getUWP().pop;
        winner = h;
      }
      
      // TO_DO: lot of casting here, look for redesign to clean this up
      if (h.getUWP().pop == maxPop){
        if (winner != null){                                                           // runtime null pointer error, though in practice this should always be assigned by this point
          if (((Orbit)h).isHabitableZone() || ((Orbit)winner).isHabitableZone()){      // habitable zone wins
            if (((Orbit)h).isHabitableZone()){ 
              winner = h;
            }
          } else {                                                                     // else closest to primary
            int direction = ((Orbit)h).getOrbitNumber() - ((Orbit)winner).getOrbitNumber();      // current list ordered low to high
            if (direction < 0){                                                        // so this may be redundant, but helps if list changes
              winner = h; 
            }                                          
          }
        }
      }
    }
    

    if (winner != null){                                                               // potential runtime null pointer error here too to guard against
      winner.setMainworld(true);                                 
      winner.completeUWP();
      ((System_ScoutsEx)_star.parent).mainworld = winner;      /// TO_DO: need to rethink return value for this method... this is a hack
    }

    // need a separate loop as this depends on the value of the mainworld flag    
    for (Habitable h : candidates){
      if (!h.isMainworld()){
        h.completeUWP();
      }
    }
    
    return winner;
  }
}