abstract class Orbit {
  Star barycenter;  // what happens with satellites orbiting planets? go with this for now, will need adjustment
  Object contents;  // and here - do we want a superclass that encompasses all entities?
  int number;
  String zone;
  
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

class Planet extends Orbit {}
//class Star extends Orbit {}
class GasGiant extends Orbit {}
class Empty extends Orbit {}
class Forbidden extends Orbit {}

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