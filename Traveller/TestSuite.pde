class TestSuite {  
  void run(){
    println("\nTesting " + subs.name);
    println("Ruleset: " + rules[currentRules]);
    println(runTest(new NavalBaseOnlyAtABStarports()));
    println(runTest(new ScoutBaseOnlyAtABCDStarports()));
    println(runTest(new NoRoutesToRedZones()));
    println(runTest(new UnoccupiedSystemsHaveNoUWP()));
    println(runTest(new SizeZeroWorldsHaveNoAtmosphere()));
    println(runTest(new SizeZeroWorldsHaveNoHydrosphere()));
  }
  
  // runs at the subsector level across all occupied systems
  // may eventually need to split the iterator away and/or
  // create variant test cases or suites against other targets
  String runTest(TestCase _t){
    String result = "";
    
    for (System s : subs.systems.values()){
      _t.run(s);
    }
    
    result += _t.getTitle();
    result += _t.getResult();
    if (_t.getDetails().length() > 1){
      result += _t.getDetails();
    }
    return result;
  }
}
// ===========================================================================

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


// ===========================================================================
class TestCase {
  String title = "Sample test";
  String result = "";
  String details = "";
  
  void run(System _s){};
  
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
// Rings have 0 population
// Moons/Rings have the same orbital zone as their parent (barycenter)
// No null orbits remain after system is created/populated