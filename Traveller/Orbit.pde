abstract class Orbit {
  //Star barycenter;  // what happens with satellites orbiting planets? go with this for now, will need adjustment
  //Object contents;  // and here - do we want a superclass that encompasses all entities?
  int orbitNumber;
  String orbitalZone;
  
  // radius in AU & km?
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
  Empty(int _orbit){ orbitNumber = _orbit; }
  String toString(){ return "Empty "  + orbitalZone; }
}

class Forbidden extends Orbit {
  Forbidden(int _orbit){ orbitNumber = _orbit; }  
  String toString(){ return "Forbidden " + orbitalZone; }
}

class Null extends Orbit {
  Null(int _orbit){ orbitNumber = _orbit; }  
  String toString(){ return "Null " + orbitalZone; }
}

class Planet extends Orbit {}

class GasGiant extends Orbit {}