class StarBuilder {
  StarBuilder(){}
  
  void newStar(System_ScoutsEx _parent){
    Star star = new Star(_parent);
    _parent.primary = star;
    
    createCompanionsFor(star);
    createSatellitesFor(star);     // Star.createSatellites() is recursive on companion stars - need to handle this case
                                   // should there be something in createCompanions()? work this out later
    
    _parent.mainworld = star.designateMainworld();
  }
  
  void createSatellitesFor(Star _star){
    if (debug == 2){ println("Creating satellites for " + _star); }
        
    int orbitCount = _star.calculateMaxOrbits();
    if (_star.isCompanion()){ orbitCount = constrain(orbitCount, 0, floor(_star.getOrbitNumber()/2)); }
    
    _star.placeEmptyOrbits(orbitCount);
    _star.placeForbiddenOrbits(orbitCount);
    _star.placeCapturedPlanets();
    _star.placeGasGiants(orbitCount);
    _star.placePlanetoidBelts(orbitCount);
    _star.placePlanets(orbitCount);
    
    println("@@@ orbitCount = " + orbitCount);
    
    ArrayList<Star> comps = _star.getCompanions();
    for (Star c : comps){
      createSatellitesFor(c);
    }

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