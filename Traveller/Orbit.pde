abstract class Orbit {
  Orbit barycenter;  // not _exactly_ the right word, but closest to meaning of "thing I orbit around"
  String name;     
  int orbitNumber;
  String orbitalZone;
  // radius in AU & km? as a query method?
  
  TreeMap<Integer, Orbit> orbits;
  
  Dice roll;
  
  Orbit(Orbit _barycenter, int _orbit, String _zone){
    if (_barycenter != null){
      if (debug == 2){ println("** Orbit ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    } else {
      if (debug == 2){ println("** Orbit PRIMARY ctor(null, " + _orbit + ", " + _zone + ")"); }
    }
    barycenter = _barycenter;
    orbitNumber = _orbit;
    orbitalZone = _zone;

    orbits = new TreeMap();

    roll = new Dice();
  }

  // pulled this method up to avoid duplication in GasGiant & Planet
  //  however, that means we need the moons list and generateSatelliteSize()
  //  in this class, even though most of the hierarchy does not use... may
  //  reverse this one but try it out for now
  // also, similarly named method in Star needs evaluation
  void createSatellites(int _satelliteCount){
    if (debug == 2){ println("**** Orbit.createSatellites(" + _satelliteCount + ") for " + this.getClass()); }
    if (_satelliteCount <= 0){
      if (debug == 2){ println("**** No satellites for " + this.getClass()); }
    } else {
      for (int i = 0; i < _satelliteCount; i++){
        int satelliteSize = generateSatelliteSize();     // just like with Planet/Planetoid, should we let UWP sort it out?
        if (satelliteSize == 0){
          if (debug == 2){  println("****** generating Ring for " + this.getClass()); }
          int orbitNum = generateSatelliteOrbit(i, true); 
          orbits.put(orbitNum, new Ring(this, orbitNum, this.orbitalZone));
        } else {
          int orbitNum = generateSatelliteOrbit(i, false);
          if (debug == 2){ println("****** generating Moon for " + this.getClass()); }
          orbits.put(orbitNum, new Moon(this, orbitNum, this.orbitalZone, satelliteSize));
        }
      }
    }
  }
  
  ArrayList<Habitable> getAllHabitables(){
    ArrayList<Habitable> result = new ArrayList();
    
    if (isHabitable()){
      result.add((Habitable)this);
    }
    
    if (isContainer()){
      for (int i : orbits.keySet()){
        Orbit child = orbits.get(i);
        result.addAll(child.getAllHabitables());
      }
    }
    
    return result;
  }
  
  // TO_DO: clear pattern between this and the Habitable query
  //   should refactor this to a templatized function 
  ArrayList<GasGiant> getAllGasGiants(){
    ArrayList<GasGiant> result = new ArrayList();
    
    if (isGasGiant()){
      result.add((GasGiant)this);
    }
    
    if (isContainer()){
      for (int i : orbits.keySet()){
        Orbit child = orbits.get(i);
        result.addAll(child.getAllGasGiants());
      }
    }
    
    return result;
  }
  
  // The original implementation for this method was closely based on the Scouts text
  // however, that method runs into infinite regression and stack overflow
  // when there are many moons (most likely case if there are more than three rings)
  // because retries can never find an available slot.
  //
  // This alternate approach has roughly the same spread, if not exactly the same
  // distribution biases. Rings will take orbits closer in; moons tend to cluster after
  // that, and extreme orbits only get assigned for Gas Giants (either via the 12+ roll
  // or because there are many moons and the options closer in are pruned away).
  int generateSatelliteOrbit(int _counter, Boolean _ring){
    // data from table on Scouts p. 28 (corresponding text on pp.36-7)  
    IntList availableOrbits = new IntList();
    availableOrbits.append( new int[]{1,1,1,2,2,3,3,4,5,6,7,8,9,10,11,12,13,15,20,25,30,35,40,45,50,55,60,65,75,100,125,150,175,200,225,250,275,300,325} );
    prune(availableOrbits);
    
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
        if (dieThrow >= 12 && isGasGiant()){      // Extreme orbits
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

  void prune(IntList _list){
    for (int i = _list.size()-1; i >= 0; i--){
      if (orbitIsTaken(_list.get(i))){
        _list.remove(i);
      }
    }
  }

  Boolean orbitIsTaken(int _orbit){
    return orbits.keySet().contains(_orbit);
  }

  int generateSatelliteSize(){ return 0; }  // keeping the compiler happy - see note above in createSatellites()

  Boolean isOrbitingClassM(){
    if (debug == 2){ println("**** Orbit.isOrbitingClassM() for " + this.getClass()); }
    if (barycenter.isStar()){
      return ((Star)barycenter).type == 'M';
    } else {
      return false;
    }
  }

  Boolean isInnerZone(){
    if (debug == 2){ println("**** Orbit.isInnerZone() for " + this.getClass()); }
    return orbitalZone.equals("I");
  }
  
  Boolean isHabitableZone(){
    if (debug == 2){ println("**** Orbit.isHabitableZone() for " + this.getClass()); }
    return orbitalZone.equals("H");
  }
  
  Boolean isOuterZone(){
    if (debug == 2){ println("**** Orbit.isOuterZone() for " + this.getClass()); }
    return orbitalZone.equals("O");
  }

  // TO_DO: we could greatly simplify this by adding another code to the data tables...
  //  but then we would have to OR the symbols together for outer zone queries, think about it
  Boolean isAtLeastTwoBeyondHabitable(){
    if (debug == 2){ println("**** Orbit.isAtLeastTwoBeyondHabitable() for " + this.getClass()); }
    if (isInnerZone() || isHabitableZone()){ return false; }
    if (barycenter.isPlanet()){ return ((Planet)barycenter).isAtLeastTwoBeyondHabitable(); }
    if (barycenter.isGasGiant()){ return ((GasGiant)barycenter).isAtLeastTwoBeyondHabitable(); }
    
    // find habitable zone (move this to method on Star? esp now that we have to downcast)
    int habitableOrbit = 0;
    Boolean foundHabitable = false;
    for (int i = 0; i < ((Star)barycenter).orbitalZones.length; i++){
      if (((Star)barycenter).orbitalZones[i].equals("H")){
        habitableOrbit = i;
        foundHabitable = true;
        break;
      }
    }

    // by RAW, undefined case: system has no habitable zone - we'll go with TRUE
    if (!foundHabitable){
      if (debug >= 1){ println("No habitable zone for " + barycenter); }
      return true;      
    } else {
      if (debug >= 1){ println("Habitable zone for " + barycenter + " in orbit " + habitableOrbit); }
      return (orbitNumber - habitableOrbit >= 2);
    }
  }  
  
  Boolean isContainer(){
    return orbits.size() > 0;
  }
  
  Boolean isStar(){ return false; }
  Boolean isEmpty(){ return false; }
  Boolean isForbidden(){ return false; }
  Boolean isNull(){ return false; }  
  Boolean isGasGiant(){ return false; }
  Boolean isPlanet(){ return false; }
  Boolean isPlanetoid(){ return false; }
  Boolean isMoon(){ return false; }
  Boolean isRing(){ return false; }
  Boolean isHabitable(){ return false; }

  String toString(){ 
    if (isHabitable()){
      return name + " " + ((Habitable)this).getUWP() + " " + ((Habitable)this).getFacilities();
    } else {
      return name;
    }
  }
}

//class Star extends Orbit {} // separate file/tab for this one

class Empty extends Orbit {
  Empty(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Empty " + orbitNumber + "-" + orbitalZone;
  }
  
  Boolean isEmpty(){ return true; }
}

class Forbidden extends Orbit {
  Forbidden(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Forbidden " + orbitNumber + "-" + orbitalZone;
  }
  
  Boolean isForbidden(){ return true; }
}

class Null extends Orbit {
  Null(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Null " + orbitNumber + "-" + orbitalZone;
  }  
  
  Boolean isNull(){ return true; }
}

class GasGiant extends Orbit {
  String size;       // potential to split this type code into subclasses, polymorphic logic below
    
  GasGiant(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** GasGiant ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    if (roll.one() >= 4){ 
      size = "S";
    } else {
      size = "L";
    }

    int satelliteCount = generateSatelliteCount();
    createSatellites(satelliteCount);
    
    name = size + "GG " + orbitNumber + "-" + orbitalZone;
  }  

  int generateSatelliteCount(){
    int result = 0;
    if (size.equals("S")){ 
      result = roll.two(-4);
    } else if (size.equals("L")){
      result = roll.two();
    }
    return result;
  }
  
  int generateSatelliteSize(){
    int result = 0;
    if (size.equals("S")){
      result = roll.two(-6); 
    } else if (size.equals("L")){
      result = roll.two(-4);          
    }
    return result;
  }
  
  Boolean isGasGiant(){ return true; }

  String toString(){    // temporary override so we can peek at the structure
    String result = super.toString();
    result += " " + orbits.toString();
    return result;
  }
}

interface Habitable {   // distinct from "Habitable Zone" - this just means "has a UWP"
  abstract UWP getUWP();
  abstract UWP_ScoutsEx generateUWP();
  abstract void setMainworld(Boolean _isMainworld);
  abstract Boolean isMainworld();
  abstract void completeUWP();
  abstract void addFacility(String _facility);
  abstract ArrayList<String> getFacilities();
}

class Planet extends Orbit implements Habitable { 
  UWP_ScoutsEx uwp;
  Boolean mainworld;
  ArrayList<String> facilities;
  
  Planet(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** Planet ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    uwp = generateUWP();

    int satelliteCount = generateSatelliteCount();
    createSatellites(satelliteCount);

    name = "Planet " + orbitNumber + "-" + orbitalZone;
    mainworld = false;
    facilities = new ArrayList();
  }
  
  UWP getUWP(){ return uwp; }
    
  int generateSatelliteCount(){
    int result = roll.one(-3);
    if (result <= 0 || isMoon() || uwp.size <= 0){ result = 0; }
    return result;
  }
    
  int generateSatelliteSize(){
    return this.uwp.size - roll.one();
  }
  
  UWP_ScoutsEx generateUWP(){
    if (debug == 2){ println("**** Planet.generateUWP() for " + this.getClass()); }
    return new UWP_ScoutsEx(this);
  }

  void setMainworld(Boolean _isMainworld){ mainworld = _isMainworld; }
  Boolean isMainworld(){ return mainworld; }

  void completeUWP(){
    uwp.completeUWP(mainworld);
  }

  void addFacility(String _facility){
    facilities.add(_facility);
  }

  ArrayList<String> getFacilities(){
    return facilities;
  }

  Boolean isPlanet(){ return true; }
  Boolean isHabitable(){ return true; }
  
  String toString(){    // temporary override so we can peek at the structure
    String result = super.toString();
    result += " " + orbits.toString();
    return result;
  }
}

class Planetoid extends Orbit implements Habitable {
  UWP_ScoutsEx uwp;
  Boolean mainworld;
  ArrayList<String> facilities;
  
  Planetoid(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone); 
    uwp = generateUWP();
    name = "Planetoid Belt " + orbitNumber + "-" + orbitalZone;
    mainworld = false;
    facilities = new ArrayList();
  }

  UWP getUWP(){ return uwp; }

  UWP_ScoutsEx generateUWP(){
    return new UWP_ScoutsEx(this);
  }

  void setMainworld(Boolean _isMainworld){ mainworld = _isMainworld; }
  Boolean isMainworld(){ return mainworld; }

  void completeUWP(){
    uwp.completeUWP(mainworld);
  }

  void addFacility(String _facility){
    facilities.add(_facility);
  }

  ArrayList<String> getFacilities(){
    return facilities;
  }

  Boolean isPlanetoid(){ return true; }
  Boolean isHabitable(){ return true; }
}

// uncertain if following subclasses are needed
// Satellite is a Planet whose barycenter is not a Star (i.e. GasGiant or Planet)
// Ring is a Planetoid whose barycenter is not a Star (i.e. GasGiant or Planet)
// could just do this via queries

class Moon extends Planet {
  // need to work through inherited fields and hierarchy for these second-level children

  Moon(Orbit _barycenter, int _orbit, String _zone, int _size){
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** Moon ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ", " + _size + ")"); }
    
    uwp = generateUWP(_size); // super generates a UWP but doesn't have a size parameter
                              // and doing this via polymorphism seems like more code than
                              // this way
       
    name = "Moon " + _barycenter.orbitNumber + ":" + orbitNumber + "-"  + orbitalZone;
  }
  
  UWP_ScoutsEx generateUWP(int _size){
    return new UWP_ScoutsEx(this, _size);
  }
  
  Boolean isMoon(){ return true; }
}

class Ring extends Planetoid {
  Ring(Orbit _barycenter, int _orbit, String _zone){
    super(_barycenter, _orbit, _zone);
    name = "Ring " + _barycenter.orbitNumber + ":" + orbitNumber + "-" + orbitalZone;
  }
  
  Boolean isRing(){ return true; }
}