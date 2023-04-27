abstract class Orbit {
  Star barycenter;  // what happens with satellites orbiting planets? go with this for now, will need adjustment
  String name;      //    also not _exactly_ the right word, but closest to meaning of "thing I orbit around"
  int orbitNumber;
  String orbitalZone;
  // radius in AU & km? as a query method?
  
  Orbit(Star _barycenter, int _orbit, String _zone){
    barycenter = _barycenter;
    orbitNumber = _orbit;
    orbitalZone = _zone;
  }
  
  String toString(){ return name; }
}

// some thoughts about the structure and potential inheritance hierarchy

// Primary Star
// Orbits
//   Companion Star
//   Planet (including Asteroid belts) - have a UWP
//   Gas Giant (handled separately due to Traveller convention)
//   Satellite (including Rings) - have a UWP
//   Empty
//   Forbidden (does this need to be distinct from 'Empty'?)

// Does this make sense? Move array out of System into Star...

// System.primary
//   primary.barycenter = self
//   primary.contents = new Star()
//   primary.number = null
//   primary.zone = null
//   primary.orbits[] = new Orbit[]

//   primary.orbits[n] = new Star()
//   primary.orbits[n] = new Planet()
//   primary.orbits[n] = new GasGiant()

//     primary.orbits[n].orbits[] = new Orbit[]
//     primary.orbits[n].orbits[o] = new Star()
//     primary.orbits[n].orbits[o] = new Planet() ...

//   primary.orbits[n] = new Empty()
//   primary.orbits[n] = new Forbidden()

//class Star extends Orbit {} // separate file/tab for this one

class Empty extends Orbit {
  Empty(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Empty " + orbitalZone;
  }
}

class Forbidden extends Orbit {
  Forbidden(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Forbidden " + orbitalZone;
  }  
}

class Null extends Orbit {
  Null(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    name = "Null " + orbitalZone;
  }  
}

class GasGiant extends Orbit {
  String size;
  
  GasGiant(Star _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
    if (oneDie() >= 4){ 
      size = "S";
    } else {
      size = "L";
    }
    name = size + "GG " + orbitalZone;
  }  
}


class Planet extends Orbit {
  Boolean isPlanetoid;
  UWP_ScoutsEx uwp;
  
  Planet(Star _barycenter, int _orbit, String _zone, Boolean _planetoid){ 
    super(_barycenter, _orbit, _zone);
    
    isPlanetoid = _planetoid;
  
    uwp = new UWP_ScoutsEx(this);

    if (isPlanetoid){
      name = "Planetoid Belt " + orbitalZone + " " + uwp;
    } else {
      name = "Planet " + orbitalZone + " " + uwp;
    }
  }
  
  // the following query methods might be useful on the parent
  //  currently only used by Planet and its components, though
  Boolean isOrbitingClassM(){
    return barycenter.type == 'M';
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
  
  Boolean isAtLeastTwoBeyondHabitable(){    
    if (isInnerZone() || isHabitableZone()){ return false; }
    
    // find habitable zone (move this to method on Star?)
    int habitableOrbit = 0;
    Boolean foundHabitable = false;
    for (int i = 0; i < barycenter.orbitalZones.length; i++){
      if (barycenter.orbitalZones[i].equals("H")){
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