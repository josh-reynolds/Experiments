abstract class Orbit {
  //Star barycenter;  // what happens with satellites orbiting planets? go with this for now, will need adjustment
  //Object contents;  // and here - do we want a superclass that encompasses all entities?
  // radius in AU & km?
  String name;
  int orbitNumber;
  String orbitalZone;
  
  Orbit(int _orbit, String _zone){
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
  Empty(int _orbit, String _zone){ 
    super(_orbit, _zone);
    name = "Empty " + orbitalZone;
  }
}

class Forbidden extends Orbit {
  Forbidden(int _orbit, String _zone){ 
    super(_orbit, _zone);
    name = "Forbidden " + orbitalZone;
  }  
}

class Null extends Orbit {
  Null(int _orbit, String _zone){ 
    super(_orbit, _zone);
    name = "Null " + orbitalZone;
  }  
}

class GasGiant extends Orbit {
  String size;
  
  GasGiant(int _orbit, String _zone){ 
    super(_orbit, _zone);
    if (oneDie() >= 4){ 
      size = "S";
    } else {
      size = "L";
    }
    name = size + "GG " + orbitalZone;
  }  
}

class Planet extends Orbit {
  Planet(int _orbit, String _zone){ 
    super(_orbit, _zone);
    name = "Planet " + orbitalZone;
  }  
}