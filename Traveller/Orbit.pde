abstract class Orbit {
  Orbit barycenter;  // not _exactly_ the right word, but closest to meaning of "thing I orbit around"
  String name;     
  int orbitNumber;
  String orbitalZone;
  // radius in AU & km? as a query method?
  
  TreeMap<Integer, Habitable> moons; // now very similar to the implementation in Star
                                     // should assess unifying once we get moons working
  
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

    moons = new TreeMap();

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
    } else {
      for (int i = 0; i < _satelliteCount; i++){
        int satelliteSize = generateSatelliteSize();     // just like with Planet/Planetoid, should we let UWP sort it out?
        if (satelliteSize == 0){
          if (debug == 2){  println("****** generating Ring for " + this.getClass()); }
          moons.put(generateSatelliteOrbit(i, true), new Ring(this, this.orbitalZone));
        } else {
          if (debug == 2){ println("****** generating Moon for " + this.getClass()); }
          moons.put(generateSatelliteOrbit(i, false), new Moon(this, this.orbitalZone, satelliteSize));
        }
      }
    }
  }

  // table from Scouts p. 28 (text on pp.36-7)
  int generateSatelliteOrbit(int _counter, Boolean _ring){ 
    int result = 0;
    if (_ring){
      int dieThrow = roll.one();
      switch(dieThrow){
        case 1:
        case 2:
        case 3:
          result = 1;
          break;        
        case 4:
        case 5:
          result = 2;
          break;
        case 6:
          result = 3;
          break;
        default:
          result = 1;
      }
    } else {
      // table omits, but text says "apply a DM for each throw after first equal to the throw number - 1"
      // slightly ambiguous, but give the semicolon it seems to apply only to this first 'type' throw
      // this does mean that only the first moon of a Gas Giant can have an extreme orbit
      int firstDieThrow = roll.two(-_counter);
      int secondDieThrow = roll.two();
      if (firstDieThrow < 8){                       // Close orbits
        result = secondDieThrow + 1;
      } else {
        if (isGasGiant() && firstDieThrow >= 12){   // Extreme orbits
          result = (secondDieThrow * 25) + 25;
        } else {                                    // Far orbits
          result = (secondDieThrow + 1) * 5;
        }
      }
    }

    // throw again if orbit already assigned
    // this will be a problem if there are more than three rings...
    // we don't have an exit base case for this recursion
    if (moons.keySet().contains(result)){ result = generateSatelliteOrbit(_counter, _ring); }
    
    return result;
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
  
  Boolean isStar(){ return false; }
  Boolean isEmpty(){ return false; }
  Boolean isForbidden(){ return false; }
  Boolean isNull(){ return false; }  
  Boolean isGasGiant(){ return false; }
  Boolean isPlanet(){ return false; }
  Boolean isPlanetoid(){ return false; }
  Boolean isMoon(){ return false; }
  Boolean isRing(){ return false; }

  String toString(){ return name; }
}

//class Star extends Orbit {} // separate file/tab for this one

class Empty extends Orbit {
  Empty(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Empty " + orbitalZone;
  }
  
  Boolean isEmpty(){ return true; }
}

class Forbidden extends Orbit {
  Forbidden(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Forbidden " + orbitalZone;
  }
  
  Boolean isForbidden(){ return true; }
}

class Null extends Orbit {
  Null(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Null " + orbitalZone;
  }  
  
  Boolean isNull(){ return true; }
}

class GasGiant extends Orbit {
  String size;       // potential to split this type code into subclasses, polymorphic logic below
    
  GasGiant(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** GasGiant ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    if (roll.one() >= 4){ 
      size = "S";
    } else {
      size = "L";
    }

    int satelliteCount = generateSatelliteCount();
    createSatellites(satelliteCount);
    
    name = size + "GG " + orbitalZone;
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
    result += " " + moons.toString();
    return result;
  }
}

interface Habitable {   // distinct from "Habitable Zone" - this just means "has a UWP"
  abstract UWP_ScoutsEx generateUWP();
}

class Planet extends Orbit implements Habitable { 
  UWP_ScoutsEx uwp;
  
  Planet(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** Planet ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    uwp = generateUWP();

    int satelliteCount = generateSatelliteCount();
    createSatellites(satelliteCount);

    name = "Planet " + orbitalZone + " " + uwp;
  }
    
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

  Boolean isPlanet(){ return true; }
  
  String toString(){    // temporary override so we can peek at the structure
    String result = super.toString();
    result += " " + moons.toString();
    return result;
  }
}

class Planetoid extends Orbit implements Habitable {
  UWP_ScoutsEx uwp;

  Planetoid(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone); 
    uwp = generateUWP();
    name = "Planetoid Belt " + orbitalZone + " " + uwp;
  }

  UWP_ScoutsEx generateUWP(){
    return new UWP_ScoutsEx(this);
  }

  Boolean isPlanetoid(){ return true; }
}

// uncertain if following subclasses are needed
// Satellite is a Planet whose barycenter is not a Star (i.e. GasGiant or Planet)
// Ring is a Planetoid whose barycenter is not a Star (i.e. GasGiant or Planet)
// could just do this via queries

class Moon extends Planet {
  // need to work through inherited fields and hierarchy for these second-level children

  Moon(Orbit _planet, String _zone, int _size){
    super(_planet, _planet.orbitNumber, _zone);
    if (debug == 2){ println("** Moon ctor(" + _planet.getClass() + ", " + _zone + ", " + _size + ")"); }
    
    uwp = generateUWP(_size); // super generates a UWP but doesn't have a size parameter
                              // and doing this via polymorphism seems like more code than
                              // this way
       
    name = "Moon " + orbitalZone + " " + uwp;
  }
  
  UWP_ScoutsEx generateUWP(int _size){
    return new UWP_ScoutsEx(this, _size);
  }
  
  Boolean isMoon(){ return true; }
}

class Ring extends Planetoid {
  Ring(Orbit _planet, String _zone){
    super(_planet.barycenter, _planet.orbitNumber, _zone);
    name = "Ring " + orbitalZone + " " + uwp;
  }
  
  Boolean isRing(){ return true; }
}