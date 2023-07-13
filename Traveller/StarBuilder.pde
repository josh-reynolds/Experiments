class StarBuilder {
  StarBuilder(){}
  
  void newStar(System_ScoutsEx _parent){
    Star star = new Star(_parent);
    _parent.primary = star;
    
    star.createSatellites();
    
    _parent.mainworld = star.designateMainworld();
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