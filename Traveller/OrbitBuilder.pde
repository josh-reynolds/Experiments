class OrbitBuilder {
  Dice roll;  

  OrbitBuilder(){
    roll = new Dice();
  }
  
  void newPrimary(System _parent){
    Star star = ruleset.newStar(_parent);
    _parent.primary = star;
    
    createCompanionsFor(star);     // aren't companions just a special-case satellite? unify this and work with the composite structure
    createSatellitesFor(star);     // Star.createSatellites() is recursive on companion stars - need to handle this case
    designateMainworldFor(star);   // should there be something in createCompanions()? work this out later
  }

  // ================================================================
  // CREATE COMPANIONS
  // ================================================================

  protected void createCompanionsFor(Star _star){
    if (debug == 2){ println("Creating companions for " + _star); }
    int compCount = 0;
    if (_star.isPrimary() || _star.isFar()){
      compCount = generateCompanionCountFor(_star);
    }    
    if (debug >= 1){ println(compCount + " companions"); }

    for (int i = 0; i < compCount; i++){
      int orbitNum = generateCompanionOrbitFor(_star, i);
      
      Star companion = ruleset.newStar(_star, orbitNum, _star.orbitalZones[orbitNum], _star.parent);

      if (orbitNum == 0 || companion.insideStar()){
        if (debug >= 1){ println("Companion in CLOSE orbit"); }        
        _star.closeCompanion = companion;        
      }

      _star.addOrbit(companion.getOrbitNumber(), companion);
    }
  }
  
  // New Era follows same procedure (T:NE p. 192)
  private int generateCompanionCountFor(Star _star){
    println("Determining companion count for " + _star);

    int modifier = 0;
    if (!_star.isPrimary()){ modifier = -1; }
    int dieThrow = roll.two(modifier);
    
    if (dieThrow < 8                 ){ return 0; }
    if (dieThrow > 7 && dieThrow < 12){ return 1; }
    if (dieThrow == 12               ){ return 2; }
    return 0;
  }

  // MegaTraveller follows the same procedure (MTRM p. 28)
  // New Era follows the same procedure (T:NE p. 194)
  int generateSatelliteCountFor(Habitable _h){
    int result = roll.one(-3);
    if (result <= 0 || ((Orbit)_h).isMoon() || _h.getUWP().size <= 0){ result = 0; }
    return result;
  }

  // MegaTraveller follows the same procedure (MTRM p. 28)
  // New Era follows the same procedure (T:NE p. 194)
  int generateSatelliteCountFor(GasGiant _g){
    int result = 0;
    if (_g.size.equals("S")){ 
      result = roll.two(-4);
    } else if (_g.size.equals("L")){
      result = roll.two();
    }
    return result;
  }

  // from tables on Scouts p.46 
  // Note: to ease handling, I am converting RAW "Close" + "Far" to equivalent orbit numbers
  private int generateCompanionOrbitFor(Star _star, int _iteration){
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
    if (dieThrow >= 12){ result = farOrbits(); }
    
    return result;

    // TO_DO: need to handle two companions landing in same orbit
  }

  protected int farOrbits(){      
    int distance = 1000 * roll.one();                           // distance in AU, converted to orbit number below
    if (distance == 2000                    ){ return 15; }
    if (distance == 3000 || distance == 4000){ return 16; }
    if (distance >= 5000                    ){ return 17; }
    return 14;                                                  // covers distance 1000 and compiler complaints
  }

  // ================================================================
  // CREATE SATELLITES
  // ================================================================

  private void createSatellitesFor(Star _star){
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
      println("Companions for " + _star);
      printArray(_star.getCompanions());
    } 
  }

  // Moving over from Orbit - hopefully merges into the one for Stars, above
  // PREVIOUS COMMENTS
  // pulled this method up to avoid duplication in GasGiant & Planet
  //  however, that means we need the moons list and generateSatelliteSize()
  //  in this class, even though most of the hierarchy does not use... may
  //  reverse this one but try it out for now
  // also, similarly named method in Star needs evaluation
  void createSatellitesFor(Orbit _o, int _satelliteCount){
    if (debug == 2){ println("**** StarBuilder.createSatellitesFor(" + _o + ", " + _satelliteCount + ") for " + _o.getClass()); }
    if (_satelliteCount <= 0){
      if (debug == 2){ println("**** No satellites for " + _o.getClass()); }
    } else {
      for (int i = 0; i < _satelliteCount; i++){
        int satelliteSize = generateSatelliteSizeFor(_o);     // just like with Planet/Planetoid, should we let UWP sort it out?
        if (satelliteSize == 0){
          if (debug == 2){  println("****** generating Ring for " + _o.getClass()); }
          int orbitNum = generateSatelliteOrbitFor(_o, i, true);
          _o.addOrbit(orbitNum, new Ring(_o, orbitNum, _o.orbitalZone));
        } else {
          if (debug == 2){ println("****** generating Moon for " + _o.getClass()); }
          int orbitNum = generateSatelliteOrbitFor(_o, i, false);
          _o.addOrbit(orbitNum, new Moon(_o, orbitNum, _o.orbitalZone, satelliteSize));
        }
      }
    }
  }

  // MegaTraveller follows the same procedure (almost, see note below) - MTRM p.28
  // New Era is copy-pasted from MT, including the error noted below - using MT errata (T:NE p. 194)
  private int generateSatelliteSizeFor(Orbit _o){
    if (_o.isGasGiant()){
      int result = 0;
      if (((GasGiant)_o).size.equals("S")){
        result = roll.two(-6); 
      } else if (((GasGiant)_o).size.equals("L")){
        result = roll.two(-4);          
      }
      return result;
    } else if (_o.isPlanet() && !_o.isMoon()){
      return ((Habitable)_o).getUWP().size - roll.one();    // MTRM p. 28 is in error (1D-Size); errata p. 22 shows the correct formula, consistent w/ Scouts
    } else {
      println("INVALID Orbit type passed to generateSatelliteSizeFor()");
      return 0;
    }
  }

  // TO_DO: review/compare Scouts against MegaTraveller - per notes below, I didn't exactly implement the Scouts procedure
  //  on a quick skim, MT appears to be the same and we shouldn't need to override
  // same story for T:NE, which looks like a copy-paste from MT (T:NE p. 195)

  // The original implementation for this method was closely based on the Scouts text
  // however, that method runs into infinite regression and stack overflow
  // when there are many moons (most likely case if there are more than three rings)
  // because retries can never find an available slot.
  //
  // This alternate approach has roughly the same spread, if not exactly the same
  // distribution biases. Rings will take orbits closer in; moons tend to cluster after
  // that, and extreme orbits only get assigned for Gas Giants (either via the 12+ roll
  // or because there are many moons and the options closer in are pruned away).
  private int generateSatelliteOrbitFor(Orbit _o, int _counter, Boolean _ring){
    // data from table on Scouts p. 28 (corresponding text on pp.36-7)  
    IntList availableOrbits = new IntList();
    availableOrbits.append( new int[]{1,1,1,2,2,3,3,4,5,6,7,8,9,10,11,12,13,15,20,25,30,35,40,45,50,55,60,65,75,100,125,150,175,200,225,250,275,300,325} );
    pruneFor(_o, availableOrbits);
    
    int low, high;
    
    // need to adapt as the list shrinks or we get out of bounds errors
    // this implementation is safe up to ~30 assignments
    // which amply covers the Scouts algorithm (LGG can have up to 12 satellites max)
    if (_ring){
      low = 0;
      high = min(availableOrbits.size()-1, low + 3);
    } else {
      // the table omits this detail, but the text says "apply a DM for each throw after first equal to the throw number - 1"
      // slightly ambiguous, but given the semicolon it seems to apply only to this first 'type' throw
      // it does mean that only the first moon of a Gas Giant can have an extreme orbit
      int dieThrow = roll.two(-_counter);
      if (dieThrow < 8){                          // Close orbits
        low = min(availableOrbits.size()-1, 6);
        high = min(availableOrbits.size()-1, low + 10);
      } else {
        if (dieThrow >= 12 && _o.isGasGiant()){      // Extreme orbits
          low = availableOrbits.size()-10;
          high = availableOrbits.size()-1;
        } else {                                  // Far orbits
          low = min(availableOrbits.size()-1, 16);
          high = min(availableOrbits.size()-1, low + 10);
        }
      }
    }                                                 
  
    int index = floor(random(low, high));
    return availableOrbits.get(index);    
  }

  private void pruneFor(Orbit _o, IntList _list){
    for (int i = _list.size()-1; i >= 0; i--){
      if (_o.orbitIsTaken(_list.get(i))){
        _list.remove(i);
      }
    }
  }

  // TO_DO: MegaTraveller errata p.22 clarifies this is the highest orbit number, not the count of total orbits
  //  since this is 0-based, we should review for off-by-one issues - some earlier struggles/bugs may
  //  have been symptoms, and the bandaids put it place inconsistent
  private int calculateMaxOrbitsFor(Star _star){   
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

  // we have shifted to TreeMap, look for opportunities to simplify/eliminate this one
  private void placeEmptyOrbitsFor(Star _star, int _maxOrbit){
    println("Determining empty orbits for " + _star);
    
    // Empty orbits per Scouts p.34 (table on p. 29)
    // MegaTraveller is identical, down to the frequencies commented below (MTRM p.28)
    // there is a typo where they omit the modifier number on the quantity roll, but assume it is
    // unchanged from Scouts (confirmed in errata: p. 22)
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

  // replacement for getRandomNullOrbit() using TreeMap structure
  // flaws with this approach still exist and should be remedied later
  // TreeMap might give us some tools to simplify
  // TO_DO: this needs to be more robust
  private int getRandomUnassignedOrbitFor(Star _star, int _maxOrbit){
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

  // three cases:
  //  - DONE  orbit is inside star (have query method)
  //  - DONE  orbit is suppressed by nearby companion star
  //  -         TO_DO (Far companion case is unclear - in RAW, they don't have an orbit num so are not evaluated in this test)
  //  - DONE  orbit is too hot to allow planets
  private void placeForbiddenOrbitsFor(Star _star, int _maxOrbit){
    println("Determining forbidden orbits for " + _star);
    for (int i = 0; i <= _maxOrbit; i++){
      if (_star.orbitIsForbidden(i) && _star.orbitIsNullOrEmpty(i)){
        _star.addOrbit(i, new Forbidden(_star, i, _star.orbitalZones[i]));
      }
    }
  }    

  protected Boolean capturedPlanetsArePresentFor(Star _star){   // parameter unused here, but needed in the MT override
    return roll.one() > 4;
  }

  protected int capturedPlanetQuantity(){ return floor(roll.one()/2); }

  private void placeCapturedPlanetsFor(Star _star){
    println("Placing Captured Planets for " + _star);
    // ambiguity here - some of the notes from Empty Orbits (above) also applies - but:
    //  - by RAW, these are placed in orbit 2-12 +/- deviation
    //  - same biases as noted under Empty: 0 & 1 protected, bell curve around 7, nothing beyond 12
    //  - no notes for what to do if orbit is occupied
    
    if (capturedPlanetsArePresentFor(_star)){
      int quantity = capturedPlanetQuantity();

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

        _star.addOrbit(capturedOrbit, new Planet(_star, effectiveOrbit, _star.orbitalZones[effectiveOrbit], this));
        Planet captured = (Planet)_star.getOrbit(capturedOrbit);
        captured.setOrbitNumber(capturedOrbit);
      }
    }        
  }  

  private float generateCapturedOrbit(){
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

  protected int generateGasGiantCountFor(Star _star){
    println("Generating Gas Giant count for " + _star);
    int gasGiantCount = 0;        
    if (roll.two() <= 9){  // for MegaTraveller, they changed the die throw to 5+, but it's the same odds (83.3%) so no need to override - MTRM p. 28
      switch(roll.two()){ 
        case 2:
        case 3:
          gasGiantCount = 1;
          break;        
        case 4:
        case 5:
          gasGiantCount = 2;
          break;        
        case 6:
        case 7:
          gasGiantCount = 3;
          break;        
        case 8:
        case 9:
        case 10:
          gasGiantCount = 4;        
          break;        
        case 11:
        case 12:
          gasGiantCount = 5;        
          break;
        default:
          gasGiantCount = 1;        
          break;
      } 
    } else {
      if (debug >= 1){ println("No Gas Giants in-system"); }      
    }
    return gasGiantCount;
  }

  protected void placeGasGiantsFor(Star _star, int _maxOrbit){
    println("Placing Gas Giants for " + _star);
    _star.gasGiantCount = generateGasGiantCountFor(_star);

    // per Scouts p. 34: "The number (of Gas Giants) may not exceed the number of available and non-empty orbits in the habitable and outer zones"
    IntList availableOrbits = availableOrbitsFor(_star, _maxOrbit);
    pruneInnerZoneFor(_star, availableOrbits);
    
    // TO_DO: one (awkward) special case:
    //   " (i)f the table calls for a gas giant and there is no orbit available for it, create an orbit in the outer zone for it"
    
    _star.gasGiantCount = min(_star.gasGiantCount, availableOrbits.size());
    if (debug >= 1){ println(_star.gasGiantCount + " Gas Giants in-system"); }  // need to consider at the System level, for Primary + all companions
    
    for (int i = 0; i < _star.gasGiantCount; i++){
      availableOrbits.shuffle();
      int index = availableOrbits.remove(0);
      _star.addOrbit(index, new GasGiant(_star, index, _star.orbitalZones[index], this));
    }
  }  

  // very close to Orbit.prune(), refactor!
  protected void pruneInnerZoneFor(Star _star, IntList _list){
    for (int i = _list.size()-1; i >= 0; i--){
      if (_star.orbitIsInnerZone(_list.get(i))){
        _list.remove(i);
      }
    }
  }
  
  // very close to pruneInnerZone..., refactor!
  protected void keepOnlyInnerZoneFor(Star _star, IntList _list){
    for (int i = _list.size()-1; i >= 0; i--){
      if (!_star.orbitIsInnerZone(_list.get(i))){
        _list.remove(i);
      }
    }
  }

  protected int generatePlanetoidBeltCountFor(Star _star){
    println("Generating Planetoid Belts count for " + _star);
    int planetoidCount = 0;        
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
    } else {
      if (debug >= 1){ println("No Planetoid Belts in-system"); }      
    }
    return planetoidCount;
  }

  // will be very similar to GasGiants, above - duplication OK for now, but look for refactorings
  private void placePlanetoidBeltsFor(Star _star, int _maxOrbit){
    println("Placing Planetoid Belts for " + _star);
    // uses # of Gas Giants as a modifier - rules don't specify, but I assume that means just for
    // the star which the potential planetoids orbit, not all companions
    int planetoidCount = generatePlanetoidBeltCountFor(_star);  // not yet needed outside this method (MT and later include this count at System level, but IIRC Scouts does not)        
    
    IntList availableOrbits = availableOrbitsFor(_star, _maxOrbit);
    planetoidCount = min(planetoidCount, availableOrbits.size());
    if (debug >= 1){ println(planetoidCount + " Planetoid Belts in-system"); }
  
    // RAW p. 35: "If possible, planetoid belts should be placed in the next orbit inward from gas giants."
    // MegaTraveller follows the same convention (MTRM p. 28)
    IntList orbitsInwardFromGiants = new IntList();
    for (int i = 0; i < availableOrbits.size(); i++){
      int index = availableOrbits.get(i);
      int possibleGasGiantLocation = index + 1;
      
      if (_star.getOrbit(possibleGasGiantLocation) != null && _star.getOrbit(possibleGasGiantLocation).isGasGiant()){
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
  }    

  protected IntList availableOrbitsFor(Star _star, int _maxOrbit){
    IntList result = new IntList();
    for (int i = 0; i <= _maxOrbit; i++){
      if (_star.orbitIsNull(i)){
        if (debug >= 1){ println("Orbit " + i + " qualifies"); }
        result.append(i);
      }
    }
    if (debug >= 1){ println("Found " + result.size() + " available orbits"); }   
    return result;
  }  

  private void placePlanetsFor(Star _star, int _maxOrbit){
    println("Placing Planets for " + _star);
    for (int i = 0; i < _maxOrbit; i++){
      if (_star.orbitIsNull(i)){
        _star.addOrbit(i, new Planet(_star, i, _star.orbitalZones[i], this));
      }
    }
  }  
  
  // ================================================================
  // DESIGNATE MAINWORLD
  // ================================================================

  // TO_DO: MT errata states: maximum population is Mainworld population -1
  //   we can't impose this until we know the mainworld, so this method (or later)
  //   is where the adjustment needs to go
  protected void designateMainworldFor(Star _star){
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
  }
}

class OrbitBuilder_MT extends OrbitBuilder {
  OrbitBuilder_MT() { super(); }

  // MegaTraveller follows the same procedure (MTRM p. 26) for generateCompanionCountFor(Star)

  // TO_DO: errata p. 22: "If two or more stars in the same system are size D, change them all to size V."
  //      need to think about where to apply this. dummy method in the super template?
  //      and also, when we change a star's size, the orbit zones need to be reloaded at a minimum. Anything else?
  //      (overkill since I would think changing a star's size is very rare during these procedures - but!
  //       we could provide a mutator method on Star that makes sure orbit zones are updated...)
  //      look for other occurrences of this

  
  // MegaTraveller RAW follows the same procedure (MTRM p. 26) for generateCompanionOrbitFor(Star)
  // However the errata changes the "Far" entry - roughly equivalent to my previous version, 
  // but range is now 14-19 (previously 14-17). orbital zones data goes up to 20, so we should be OK
  protected int farOrbits(){ return roll.one(13); }
  
  // MegaTraveller follows the same procedure (MTRM p. 26) for calculateMaxOrbitsFor(Star)

  // MegaTraveller changed the procedure for Planetoids (MTRM p. 28):
  // - present on 8+, no longer uses GasGiant count as a modifier to these odds
  // - count odds are identical, but they inverted the mapping of die roll to quantity
  // - may well be a typo here in missing GasGiant count - the table has an entry for '13' on an unmodified 2D roll
  //
  // checked the errata, and yes, they left out the GasGiant modifier in the original printing (MT errata is infamous)
  //  and I think even the errata is incomplete, since it only refers to the first roll, not the second:
  //  "If there are gas giants in the system, apply the number of gas giants as a +DM to the die roll to determine if planetoid belts exist in the system."
  //
  // also the detailed errata note is for the table on p. 25 (Step 16),
  // though technically this method is for Step 23 on p. 28
  //
  // implementing the full errata here, but also retaining the Gas Giant modifier on the second roll
  protected int generatePlanetoidBeltCountFor(Star _star){
    println("Generating Planetoid Belts count for " + _star);
    int planetoidCount = 0;        
    if (roll.two(_star.gasGiantCount) >= 8){
      switch(roll.two(_star.gasGiantCount)){ 
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
          planetoidCount = 1;
          break;
        case 7:                  // changed in errata (p. 22)
        case 8:
        case 9:
        case 10:
        case 11:
          planetoidCount = 2;
          break;
        case 12:                 // changed in errata (p. 22)
        case 13:                 // with errata change, now possible to reach these values
        case 14:
        case 15:
        case 16:
        case 17:                 // max 5 Gas Giants, so results possible up to 17
          planetoidCount = 3;    
          break;        
        default:
          planetoidCount = 1;        
          break;
      }
    } else {
      if (debug >= 1){ println("No Planetoid Belts in-system"); }      
    }
    return planetoidCount;
  }
  
  
  // MegaTraveller Captured Planet procedure is identical to Scouts except for the odds:
  // they added a modifier for type A/B stars (MTRM p. 28)
  protected Boolean capturedPlanetsArePresentFor(Star _star){
    int modifier = 0;
    if (_star.type == 'A' || _star.type == 'B'){ modifier += 1; }
    return roll.one(modifier) > 4;
  }
  
  // errata also changes the quantity calculation
  protected int capturedPlanetQuantity(){ 
    int dieThrow = roll.one();
    int result = 1;
    if (dieThrow == 4 || dieThrow == 5){ result = 2; }
    if (dieThrow == 6){ result = 3; }
    return result;
  }
  
  // MegaTraveller follows a slightly different (though probably equivalent) procedure - MTRM p.28
  protected void placeGasGiantsFor(Star _star, int _maxOrbit){
    println("Placing Gas Giants for " + _star);
    _star.gasGiantCount = generateGasGiantCountFor(_star);

    IntList allOrbits = availableOrbitsFor(_star, _maxOrbit);
    int allOrbitCount = allOrbits.size();
    
    IntList allOrbitsExceptInner = allOrbits.copy();
    pruneInnerZoneFor(_star, allOrbitsExceptInner);
    int preferredOrbitCount = allOrbitsExceptInner.size();

    // MegaTraveller omits all the special cases described in Scouts (see comments above in super.placeGasGiantsFor())
    //  other than that, the only real difference is MT allows Gas Giants in the Inner Zone after all other
    //  orbits have been assigned
    // The RAW procedure (2d-3 + habitable zone number) leads to a bunch of corner cases that need to be handled
    //  (like generating a value above the maximum orbit for the star), so we'll just use a simple random assignment
    //  like the Scouts version above, and adjust to allow Inner Zone assignment

    // CASE ONE - enough available orbits
    if (_star.gasGiantCount <= preferredOrbitCount){ 
      // assign randomly
      for (int i = 0; i < _star.gasGiantCount; i++){
        allOrbitsExceptInner.shuffle();
        int index = allOrbitsExceptInner.remove(0);
        _star.addOrbit(index, new GasGiant(_star, index, _star.orbitalZones[index], this));
      } 
    }
    
    // CASE TWO - not enough available orbits, but sufficient Inner Zone orbits to cover
    if (_star.gasGiantCount > preferredOrbitCount && _star.gasGiantCount <= allOrbitCount){ 
      int remainder = _star.gasGiantCount - preferredOrbitCount;
      
      // fill available orbits
      for (int i = 0; i < preferredOrbitCount; i++){
        int orbitNumber = allOrbitsExceptInner.get(i);
        _star.addOrbit(orbitNumber, new GasGiant(_star, orbitNumber, _star.orbitalZones[orbitNumber], this));
      }
      
      IntList onlyInnerOrbits = allOrbits.copy();
      keepOnlyInnerZoneFor(_star, onlyInnerOrbits);
      
      // assign remainder randomly to inner zone orbits
      for (int i = 0; i < remainder; i++){
        onlyInnerOrbits.shuffle();
        int index = onlyInnerOrbits.remove(0);
        _star.addOrbit(index, new GasGiant(_star, index, _star.orbitalZones[index], this));
      }
    }
    
    // CASE THREE - not enough orbits
    if (_star.gasGiantCount > allOrbitCount){ 
      // reduce count to total orbit count
      _star.gasGiantCount = allOrbitCount;
      
      // fill all orbits
      for (int i = 0; i < allOrbitCount; i++){
        int orbitNumber = allOrbits.get(i);
        _star.addOrbit(orbitNumber, new GasGiant(_star, orbitNumber, _star.orbitalZones[orbitNumber], this));
      }
    }
    
    if (debug >= 1){ println(_star.gasGiantCount + " Gas Giants in-system"); }  // need to consider at the System level, for Primary + all companions
  }
}

class OrbitBuilder_TNE extends OrbitBuilder_MT {
  // T:NE changes this back to the Scouts method (1d6 * 1000 AU) (T:NE p. 192)
  protected int farOrbits(){
    int distance = 1000 * roll.one();                           // distance in AU, converted to orbit number below
    if (distance == 2000                    ){ return 15; }
    if (distance == 3000 || distance == 4000){ return 16; }
    if (distance >= 5000                    ){ return 17; }
    return 14; 
  }
  
  // T:NE follows the same procedure as MT/Scouts for calculateMaxOrbits() (T:NE p. 192)
 
  // T:NE follows the same procedure as MT/Scouts for generateGasGiantCountFor() (T:NE p. 194) - typo in RAW, though, step is titled '21. Empty Orbits'
  
  // T:NE repeats the 'Planetoid Belt Quantity' table from MegaTraveller, but without the errata (T:NE p. 194)
  // I'm going to assume the errata applies and use the fixed MT version of placePlanetoidBelts()

  // Same story for 'Empty Orbits' - T:NE repeats MegaTraveller RAW, down to the typos - using the base class placeEmptyOrbits() (T:NE p. 194)
  
  // Again for 'Captured Planets' - T:NE uses MegaTraveller procedure (T:NE p. 194)
  
  // Again for 'Gas Giants' - T:NE uses MegaTraveller procedure (T:NE p. 194)
  
  // Again for 'Planetoid Belts' - T:NE uses MegaTraveller procedure (T:NE p. 194)
  
  // T:NE omits the 'assign mainworld' step and assumes a mainworld generated via the simple method (the 'Extension' procedure)
  // this prevents system characteristics from having any influence on the world, so I am going to stick with the designateMainworld()
  // approach already implemented for Scouts & MegaTraveller
}

// not sure yet about the proper hierarchy - I've been skipping the 'continuation' methods; arguably if they existed
// we'd have a parallel leg of this set of classes for those. In the meantime, we'll just extend/override existing classes 
class OrbitBuilder_T5 extends OrbitBuilder_TNE {
  String mainworldType = "";

  
  void newPrimary(System _parent){
    println("OrbitBuilder_T5.newPrimary()");
    
    Star star = ruleset.newStar(_parent);
    _parent.primary = star;
    
    println(_parent.primary);
    
    createCompanionsFor(star);
    
    int additionalWorlds = roll.two();
    
    mainworldType = determineMainworldType(_parent.uwp.size);
    ((System_T5)_parent).mainworldHZVariance = determineHZVariance();
    designateMainworldFor(star);
    
    // TO_DO: steps below are spread across this method and the System ctors... review and move around as appropriate
    
    //DONE System presence
    //...  Generate mainworld
    //DONE   Mainworld UWP
    //DONE   Mainworld type
    //DONE   Bases
    //...    HZ variance & climate
    //DONE   Gas Giant count
    //DONE   Planetoid belt count
    //...  Additional system characteristics
    //...    Trade classifications
    //DONE   Extensions
    //DONE   Travel Zones
    //DONE   Native Life
    //...  Stars & orbits
    //DONE   Primary
    //DONE   Companions & placement
    //DONE   Total worlds
    //...    Mainworld placement
    //       Gas Giant placement
    //       Planetoid placement
    //       Other world placement
    
    //createCompanionsFor(star);     // aren't companions just a special-case satellite? unify this and work with the composite structure
    //createSatellitesFor(star);     // Star.createSatellites() is recursive on companion stars - need to handle this case
    //designateMainworldFor(star);   // should there be something in createCompanions()? work this out later
  }

  private int determineHZVariance(){
    int flux = roll.one() - roll.one();
    int result = 0;
    
    if (flux <= -3){ result = -1; }
    if (flux >= 3 ){ result = 1; }
    
    return result;
  }

  private String determineMainworldType(int _size){
    int flux = roll.one() - roll.one();

    String result = "Close Satellite";
    if (flux <= -4){ result = "Far Satellite"; }
    if (flux >= -2){ result = "Planet"; }
    
    // by T5 RAW, Rings don't exist, and neither do Small Worlds (size S/0)
    // but mainworld type is generated before UWP size, and the system is silent
    // on what to do if a satellite is generated with size 0
    // per previous rules, Rings cannot be homeworlds, so we should add size S worlds for such satellites
    if (_size == 0 && result.equals("Planet")){ result = "Planetoid"; }
    
    return result;
  }

  protected void designateMainworldFor(Star _star){
    // mainworld satellite or planet?
    // HZ variance & climate
    // (if satellite) orbit number
    // (if satellite & GG) place GG in MW orbit
    // (if satellite & !GG) place BigWorld in MW orbit
    // (if belt) place as belt, disregard MW orbit value
    
    int hz = _star.getHabitableZoneNumber();
    
    int orbit = hz + ((System_T5)_star.parent).mainworldHZVariance;
    if (orbit < 0){ orbit = 0; }

    UWP u = _star.parent.uwp;
    
    Habitable p = null;
    switch (mainworldType){
      case "Planetoid":
        p = new Planetoid(_star, orbit, _star.orbitalZones[orbit]);
        break;
      case "Planet":
      case "Close Satellite":         // TO_DO: for the Satellite case, we first need to create a GasGiant or BigWorld to orbit
      case "Far Satellite":
        p = new Planet(_star, orbit, _star.orbitalZones[orbit], this);
    }

    _star.addOrbit(orbit, (Orbit)p);

    // TO_DO: the Planet ctor will create a UWP - will probably want to suppress eventually, but for now can replace with the pre-generated UWP
    // Actually, getting a cast exception in this part of the Planet ctor, need to un-muddle UWPBuilder hierarchy too

    p.setUWP(ruleset.newUWP((Orbit)p, u.starport, u.size, u.atmo, u.hydro, u.pop, u.gov, u.law, u.tech));
    
    p.setMainworld(true);
    
    ((System_ScoutsEx)_star.parent).mainworld = p;
    
  }

  // T5 p. 436
  protected void createCompanionsFor(Star _star){
    
    // flux for close/near/far stars in the system
    // flux for companions for each star present (including primary)
    // place stars in orbits:
    //   companion   - inside orbit 0
    //   close 1d-1  - orbits 0-1-2-3-4-5
    //   near  1d+5  - orbits 6-7-8-9-10-11
    //   far   1d+11 - orbits 12-13-14-15-16-17
    // determine type/size of all stars
    
    // May come up with a better structure later, but for now, let's do a pair of arrays:
    // 0 - Primary
    // 1 - Close
    // 2 - Near
    // 3 - Far
    Boolean[] stars      = {true,  false, false, false};
    Boolean[] companions = {false, false, false, false};
    int flux;

    for (int i = 1; i < stars.length; i++){  // primary is always present, so skip index 0
      flux = roll.one() - roll.one();
      if (flux >= 3){
        stars[i] = true;
      }
    }

    for (int i = 0; i < companions.length; i++){
      flux = roll.one() - roll.one();
      if (flux >= 3 && stars[i]){
        companions[i] = true;
      } 
    }
    
    for (int i = 1; i < stars.length; i++){
      if (stars[i]){
        int orbitNumber = floor(((i - 1) * 6) + random(6));
        Star companion = ruleset.newStar(_star, orbitNumber, _star.orbitalZones[orbitNumber], _star.parent);
        _star.addOrbit(companion.getOrbitNumber(), companion);
      }
    }
  }
}