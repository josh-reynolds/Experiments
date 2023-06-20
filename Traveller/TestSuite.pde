class TestSuite {  
  void run(){
    println("\nTesting " + subs.name);
    println("Ruleset: " + rules[currentRules]);
    println(runAgainstSubsector(new NavalBaseOnlyAtABStarports()));
    println(runAgainstSubsector(new ScoutBaseOnlyAtABCDStarports()));
    println(runAgainstSubsector(new NoRoutesToRedZones()));
    println(runAgainstSubsector(new UnoccupiedSystemsHaveNoUWP()));
    println(runAgainstSubsector(new SizeZeroWorldsHaveNoAtmosphere()));
    println(runAgainstSubsector(new SizeZeroWorldsHaveNoHydrosphere()));
    println(runOnce(new DistanceBetweenSubsectorCornersIsThirteen()));
    println(runAgainstStar(new HabitableZoneForG0VIs3()));
    println(runAgainstSubsector(new PlanetsCannotBeInForbiddenZones()));
    println(runAgainstSubsector(new PlanetoidsCannotBeInForbiddenZones()));
    println(runAgainstSubsector(new GasGiantsCannotBeInForbiddenZones()));
    println(runAgainstSubsector(new RingsHaveZeroPopulation()));
  }
  
  // runs at the subsector level across all occupied systems
  // may eventually need to split the iterator away and/or
  // create variant test cases or suites against other targets
  String runAgainstSubsector(TestCase _t){
    for (System s : subs.systems.values()){ _t.run(s); }
    return collectResults(_t);
  }

  // TO_DO: as we get more examples, this should be generalized to a fixture
  String runAgainstStar(TestCase _t){
    _t.run(new Star(true, null, "G0V"));
    return collectResults(_t);
  }
  
  String runOnce(TestCase _t){
    _t.run();
    return collectResults(_t);
  }

  String collectResults(TestCase _t){
    String result = "";
    result += _t.getTitle();
    result += _t.getResult();
    if (_t.getDetails().length() > 1){
      result += _t.getDetails();
    }
    return result;    
  }
}
// ===========================================================================

class HabitableZoneForG0VIs3 extends TestCase {
  HabitableZoneForG0VIs3(){ title = "Habitable zone for a G0V star is orbit 3"; }
  
  void run(Star _s){
    if (_s.type == 'G' && _s.decimal == 0 && _s.size == 5){ 
      String zone = _s.orbitalZones[3];
      String message = "G0V orbital zone recorded as " + zone;
      fails(!zone.equals("H"), message);
    }
  }
}

// testing distance calculation algorithm
class DistanceBetweenSubsectorCornersIsThirteen extends TestCase {
  DistanceBetweenSubsectorCornersIsThirteen(){ title = "Distance from top-left to bottom-right is 13"; }
  
  void run(){
    int distance = new Coordinate(1,1).distanceTo(new Coordinate(8,10));
    String message = "0101 to 0810 calculated as " + distance;
    fails(distance != 13, message);
  }
}

// TO_DO: additional special cases to cover for CT77 (Size 1) and Scouts (Inner Zone, etc.)
class SizeZeroWorldsHaveNoHydrosphere extends TestCase {
  SizeZeroWorldsHaveNoHydrosphere(){ title = "Size zero worlds have no hydrosphere"; }
  
  void run(System _s){
    if (_s.occupied && _s.uwp.size == 0){
      String message = _s.name + " size = " + _s.uwp.size + " hydro = " + _s.uwp.hydro;
      fails(_s.uwp.hydro > 0, message);
    }
  }
}

class SizeZeroWorldsHaveNoAtmosphere extends TestCase {
  SizeZeroWorldsHaveNoAtmosphere(){ title = "Size zero worlds have no atmosphere"; }
  
  void run(System _s){
    if (_s.occupied && _s.uwp.size == 0){
      String message = _s.name + " size = " + _s.uwp.size + " atmo = " + _s.uwp.atmo;
      fails(_s.uwp.atmo > 0, message);
    }
  }
}

class UnoccupiedSystemsHaveNoUWP extends TestCase {
  UnoccupiedSystemsHaveNoUWP(){ title = "Unoccupied Systems have no UWP"; }
  
  void run(System _s){
    if (!_s.occupied){
      String message = _s.name + " " + _s.uwp;
      fails(_s.uwp != null, message);
    }
  }
}

class NavalBaseOnlyAtABStarports extends TestCase {
  NavalBaseOnlyAtABStarports(){ title = "Naval Base only at AB Starports"; }
  
  void run(System _s){
    if (_s.navalBase){
      String message = _s.name + " " + _s.navalBase + " " + _s.uwp.starport;
      fails(_s.uwp.starport != 'A' && _s.uwp.starport != 'B', message);
    }    
  }
}

class ScoutBaseOnlyAtABCDStarports extends TestCase {
  ScoutBaseOnlyAtABCDStarports(){ title = "Scout Base only at ABCD Starports"; }
  
  void run(System _s){
    if (_s.scoutBase){
      String message = _s.name + " " + _s.scoutBase + " " + _s.uwp.starport;
      fails(_s.uwp.starport == 'E' || _s.uwp.starport == 'X', message);
    }  
  }
}

class NoRoutesToRedZones extends TestCase {
  NoRoutesToRedZones(){ title = "No routes to Red Zones"; }
  
  void run(System _s){
    if (ruleset.supportsTravelZones() && ((System_CT81)_s).travelZone.equals("Red")){
      if (_s.occupied){
        String message = _s.name + " " + ((System_CT81)_s).travelZone + " " + _s.routes.size();
        fails(_s.routes.size() > 0, message);
      }
    }
  }
}

class PlanetsCannotBeInForbiddenZones extends TestCase {
  PlanetsCannotBeInForbiddenZones(){ title = "Planets cannot be in Forbidden Zones"; }
  
  void run(System _s){
    if (ruleset.supportsStars()){
      if (_s.occupied){
        String message = _s.name;
        Star primary = ((System_ScoutsEx)_s).primary;
        
        Boolean invalidPlanet = false;
        ArrayList<Planet> planets = primary.getAll(Planet.class);        
        for (Planet p : planets){
          if (p.isMoon()){ continue; }
          if (p.barycenter != primary){ continue; }     // TO_DO: zones are assigned from primary, we get invalid results in this test unless
                                                        //   we filter them out. Loop back once we reconcile companion satellite orbital zones.
          if (primary.orbitIsForbidden(p.getOrbitNumber())){            
            invalidPlanet = true;
            message += " " + p.getOrbitNumber() + ":" + p.orbitalZone;
          }
        }

        fails(invalidPlanet, message);
      }
    }
  }
}

class PlanetoidsCannotBeInForbiddenZones extends TestCase {
  PlanetoidsCannotBeInForbiddenZones(){ title = "Planetoids cannot be in Forbidden Zones"; }
  
  void run(System _s){
    if (ruleset.supportsStars()){
      if (_s.occupied){
        String message = _s.name;
        Star primary = ((System_ScoutsEx)_s).primary;
        
        Boolean invalidPlanetoid = false;
        ArrayList<Planetoid> planetoids = primary.getAll(Planetoid.class);        
        for (Planetoid p : planetoids){
          if (p.isRing()){ continue; }
          if (p.barycenter != primary){ continue; }     // TO_DO: zones are assigned from primary, we get invalid results in this test unless
                                                        //   we filter them out. Loop back once we reconcile companion satellite orbital zones.
          if (primary.orbitIsForbidden(p.getOrbitNumber())){            
            invalidPlanetoid = true;
            message += " " + p.getOrbitNumber() + ":" + p.orbitalZone;
          }
        }

        fails(invalidPlanetoid, message);
      }
    }
  }
}

class GasGiantsCannotBeInForbiddenZones extends TestCase {
  GasGiantsCannotBeInForbiddenZones(){ title = "Gas Giants cannot be in Forbidden Zones"; }
  
  void run(System _s){
    if (ruleset.supportsStars()){
      if (_s.occupied){
        String message = _s.name;
        Star primary = ((System_ScoutsEx)_s).primary;
        
        Boolean invalidPlanet = false;
        ArrayList<GasGiant> giants = primary.getAll(GasGiant.class);        
        for (GasGiant g : giants){
          if (g.barycenter != primary){ continue; }     // TO_DO: zones are assigned from primary, we get invalid results in this test unless
                                                        //   we filter them out. Loop back once we reconcile companion satellite orbital zones.
          if (primary.orbitIsForbidden(g.getOrbitNumber())){            
            invalidPlanet = true;
            message += " " + g.getOrbitNumber() + ":" + g.orbitalZone;
          }
        }

        fails(invalidPlanet, message);
      }
    }
  }
}

class RingsHaveZeroPopulation extends TestCase {
  RingsHaveZeroPopulation(){ title = "Rings have zero population"; }
  
  void run(System _s){
    if (ruleset.supportsStars()){
      if (_s.occupied){
        String message = _s.name;
        Star primary = ((System_ScoutsEx)_s).primary;
        
        Boolean invalidPlanet = false;
        ArrayList<Ring> rings = primary.getAll(Ring.class);
        for (Ring r : rings){  
          if (r.uwp.pop > 0){            
            invalidPlanet = true;
            message += " " + r.getOrbitNumber() + ":" + r.uwp.pop;
          }
        }

        fails(invalidPlanet, message);
      }
    }
  }
}

// ===========================================================================
class TestCase {
  String title = "Sample test";
  String result = "";
  String details = "";
  
  void run(System _s){};
  
  void run(Star _s){};
  
  void run(){};
  
  void fails(Boolean _fail, String _message){
    if (_fail){
      details += "FAIL : " + _message + "\n";
      result += "F";            
    } else {
      result += ".";
    }
  }
  
  String getTitle(){
    return title + "\n";
  }
  
  String getResult(){
    return result;
  }
  
  String getDetails(){
    return "\n" + details;
  }
}

// Moons/Rings should not themselves have satellites
// Planetoids/Rings always 000 for UWP Size/Atmo/Hydro
// Moons/Rings have the same orbital zone as their parent (barycenter)
// No null orbits remain after system is created/populated   (n/a - Null class has been removed)
// Close companions are not listed as regular companions