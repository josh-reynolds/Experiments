class StarBuilder {
  StarBuilder(){}
  
  void newStar(System_ScoutsEx _parent){
    Star star = new Star(_parent);
    _parent.primary = star;
    
    createCompanionsFor(star);
    
    star.createSatellites();
    
    _parent.mainworld = star.designateMainworld();
  }
  
  void createCompanionsFor(Star _star){
    if (debug == 2){ println("Creating companions for " + _star); }
    int compCount = 0;
    //if (_star.isPrimary() || _star.orbitIsFar()){
    //  compCount = generateCompanionCount();
    //}    
    if (debug >= 1){ println(compCount + " companions"); }

    //for (int i = 0; i < compCount; i++){
    //  int orbitNum = generateCompanionOrbit(i);
      
    //  Star companion = new Star(this, orbitNum, orbitalZones[orbitNum], parent);

    //  if (orbitNum == 0 || orbitInsideStar(orbitNum)){
    //    if (debug >= 1){ println("Companion in CLOSE orbit"); }        
    //    closeCompanion = companion;        
    //  }

    //  addOrbit(companion.getOrbitNumber(), companion);
    //} 
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