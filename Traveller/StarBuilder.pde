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
    
    _parent.mainworld = star.designateMainworld();
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
        int choice = _star.getRandomUnassignedOrbit(_maxOrbit);
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
    _star.placeForbiddenOrbits(orbitCount);
    _star.placeCapturedPlanets();
    _star.placeGasGiants(orbitCount);
    _star.placePlanetoidBelts(orbitCount);
    _star.placePlanets(orbitCount);
    
    println("@@@ orbitCount = " + orbitCount);
    
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
      compCount = _star.generateCompanionCount();
    }    
    if (debug >= 1){ println(compCount + " companions"); }

    for (int i = 0; i < compCount; i++){
      int orbitNum = _star.generateCompanionOrbit(i);
      
      Star companion = new Star(_star, orbitNum, _star.orbitalZones[orbitNum], _star.parent);

      if (orbitNum == 0 || companion.insideStar()){
        if (debug >= 1){ println("Companion in CLOSE orbit"); }        
        _star.closeCompanion = companion;        
      }

      _star.addOrbit(companion.getOrbitNumber(), companion);
    } 
  }
  
  //void placePlanets(int _maxOrbit){
  //  println("Placing Planets for " + this);
  //  for (int i = 0; i < _maxOrbit; i++){
  //    if (orbitIsNull(i)){
  //      addOrbit(i, new Planet(this, i, orbitalZones[i]));
  //    }
  //  }
  //}
  
  
}