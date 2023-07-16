class StarBuilder {
  StarBuilder(){}
  
  void newStar(System_ScoutsEx _parent){
    Star star = new Star(_parent);
    _parent.primary = star;
    
    createCompanionsFor(star);
    createSatellitesFor(star);     // Star.createSatellites() is recursive on companion stars - need to handle this case
                                   // should there be something in createCompanions()? work this out later
                                   
    star.createSatellites();
    
    _parent.mainworld = star.designateMainworld();
  }
  
  void createSatellitesFor(Star _star){
    int orbitCount = _star.calculateMaxOrbits();
    if (_star.isCompanion()){ orbitCount = constrain(orbitCount, 0, floor(_star.getOrbitNumber()/2)); }
    
    //placeEmptyOrbits(orbitCount);
    //placeForbiddenOrbits(orbitCount);
    //placeCapturedPlanets();
    //placeGasGiants(orbitCount);
    //placePlanetoidBelts(orbitCount);
    //placePlanets(orbitCount);
    
    println("@@@ orbitCount = " + orbitCount);
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