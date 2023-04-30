abstract class Orbit {
  Orbit barycenter;  // not _exactly_ the right word, but closest to meaning of "thing I orbit around"
  String name;     
  int orbitNumber;
  String orbitalZone;
  // radius in AU & km? as a query method?
  
  Orbit(Orbit _barycenter, int _orbit, String _zone){
    barycenter = _barycenter;
    orbitNumber = _orbit;
    orbitalZone = _zone;
  }
  
  Boolean isStar(){ return false; }
  Boolean isEmpty(){ return false; }
  Boolean isForbidden(){ return false; }
  Boolean isNull(){ return false; }  
  Boolean isGasGiant(){ return false; }
  Boolean isPlanet(){ return false; }
  Boolean isPlanetoid(){ return false; }
  Boolean isSatellite(){ return false; }
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
  String size;
  int satelliteCount; // see notes below in Planet
  
  GasGiant(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    if (roll.one() >= 4){ 
      size = "S";
      satelliteCount = roll.two() - 4;
    } else {
      size = "L";
      satelliteCount = roll.two();
    }
    if (satelliteCount < 0){ satelliteCount = 0; }
    name = size + "GG " + orbitalZone + " " + satelliteCount;
  }  
  
  Boolean isGasGiant(){ return true; }
}

abstract class Habitable extends Orbit {
  Habitable(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
  }
  
  Boolean isOrbitingClassM(){
    if (barycenter.isStar()){
      return ((Star)barycenter).type == 'M';
    } else {
      return false;
    }
  }
    
  Boolean isInnerZone(){
    return orbitalZone.equals("I");
  }
  
  Boolean isHabitableZone(){
    return orbitalZone.equals("H");
  }
  
  Boolean isOuterZone(){
    return orbitalZone.equals("O");
  }
  
  // TO_DO: we could greatly simplify this by adding another code to the data tables...
  Boolean isAtLeastTwoBeyondHabitable(){    
    if (isInnerZone() || isHabitableZone()){ return false; }
    if (barycenter.isPlanet()){ return ((Planet)barycenter).isAtLeastTwoBeyondHabitable(); }
    // TO_DO: need to pull this up for satellites of GasGiants - will break once we start constructing them
    
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
      println("No habitable zone for " + barycenter);
      return true;      
    } else {
      println("Habitable zone for " + barycenter + " in orbit " + habitableOrbit);
      return (orbitNumber - habitableOrbit >= 2);
    }
  }
}

class Planet extends Habitable {
  UWP_ScoutsEx uwp;
  int satelliteCount = 0; // probably becomes a list soon, no need for a field
                          // also, only Planet & GasGiant need out of all the leaf classes in this tree
                          // but their common parent is at the root (Orbit)
                          // should this be an interface? overkill for now on just one field
  Habitable[] moons; // common parent for Satellites and Rings 
  
  Planet(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    uwp = new UWP_ScoutsEx(this);
    if (uwp.size > 0){                                         // Satellites pass through this via super ctor, need to handle properly
      satelliteCount = roll.one() - 3;
      if (satelliteCount <= 0){ 
        satelliteCount = 0;
        moons = new Habitable[0];
      } else {
        moons = new Habitable[satelliteCount];
        for (int i = 0; i < satelliteCount; i++){
          int size = this.uwp.size - roll.one();                  // just like with Planet/Planetoid, should we let UWP sort it out?
          if (size == 0){
            moons[i] = new Ring(this, this.orbitalZone);
          } else {
            moons[i] = new Satellite(this, this.orbitalZone);   // need to consider how to handle size 'S' moons
          }
        }
      }
    }
    name = "Planet " + orbitalZone + " " + uwp + " " + satelliteCount;
  }
  
  String toString(){    // temporary override so we can peek at the structure
    String result = super.toString();
    
    if (moons != null){
      for (int i = 0; i < moons.length; i++){ 
        result += "\n\t" + moons[i];
      }
    }
    
    return result;
  }
  
  Boolean isPlanet(){ return true; }
}

class Planetoid extends Habitable {
  UWP_ScoutsEx uwp;
  
  Planetoid(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);  
    uwp = new UWP_ScoutsEx(this);
    name = "Planetoid Belt " + orbitalZone + " " + uwp;
  }

  Boolean isPlanetoid(){ return true; }
}

// uncertain if following subclasses are needed
// Satellite is a Planet whose barycenter is not a Star (i.e. GasGiant or Planet)
// Ring is a Planetoid whose barycenter is not a Star (i.e. GasGiant or Planet)
// could just do this via queries

class Satellite extends Planet {
  // need to work through inherited fields and hierarchy for these second-level children
  
  Satellite(Orbit _planet, String _zone){
    super(_planet.barycenter, _planet.orbitNumber, _zone);   
  }
  
  Boolean isSatellite(){ return true; }
}

class Ring extends Planetoid {
  Ring(Orbit _planet, String _zone){
    super(_planet.barycenter, _planet.orbitNumber, _zone);
  }
  
  Boolean isRing(){ return true; }
}