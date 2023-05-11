class TestSuite {  
  void run(){
    println("\nTesting " + subs.name);
    println("Ruleset: " + rules[currentRules]);
    println(runTest(new NavalBaseOnlyAtABStarports()));
    println(runTest(new ScoutBaseOnlyAtABCDStarports()));
    println(runTest(new NoRoutesToRedZones()));
  }
  
  // runs at the subsector level across all occupied systems
  // may eventually need to split the iterator away and/or
  // create variant test cases or suites against other targets
  String runTest(TestCase _t){
    String result = "";
    
    for (System s : subs.systems.values()){
      if (s.occupied){
        _t.run(s);
      }
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

class NavalBaseOnlyAtABStarports extends TestCase {
  NavalBaseOnlyAtABStarports(){
    title = "Naval Base only at AB Starports";
  }
  
  void run(System s){
    if (s.navalBase){
      String message = s.name + " " + s.navalBase + " " + s.uwp.starport;
      fails(s.uwp.starport != 'A' && s.uwp.starport != 'B', message);
    }    
  }
}

class ScoutBaseOnlyAtABCDStarports extends TestCase {
  ScoutBaseOnlyAtABCDStarports(){
    title = "Scout Base only at ABCD Starports";
  }
  
  void run(System s){
    if (s.scoutBase){
      String message = s.name + " " + s.scoutBase + " " + s.uwp.starport;
      fails(s.uwp.starport == 'E' || s.uwp.starport == 'X', message);
    }  
  }
}

class NoRoutesToRedZones extends TestCase {
  NoRoutesToRedZones(){
    title = "No routes to Red Zones";
  }
  
  void run(System s){
    if (ruleset.supportsTravelZones()){
      String message = s.name + " " + ((System_CT81)s).travelZone + " " + s.routes.size();
      fails(((System_CT81)s).travelZone.equals("Red") && s.routes.size() > 0, message);
    }
  }
}


// ===========================================================================
class TestCase {
  String title = "Sample test";
  String result = "";
  String details = "";
  
  void run(System s){}
  
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