class TestSuite {
 
  TestSuite(){}
  
  void run(){
    println("\nTesting " + subs.name);
    println("Ruleset: " + rules[currentRules]);
    println(navalBaseOnlyAtABStarports());
    println(scoutBaseOnlyAtABCDStarports());
    println(noRoutesToRedZones());
  }
  
  String navalBaseOnlyAtABStarports(){
    Boolean pass = true;
    String result = "";
    for (System s : subs.systems.values()){
      if (s.occupied){
        if (s.navalBase){
          if (s.uwp.starport != 'A' && s.uwp.starport != 'B'){
            result += "FAIL : " + s.name + " " + s.navalBase + " " + s.uwp.starport + "\n";
          }
        }
      }
    }

    println("Naval Base only at AB Starports");
    if (pass){
      return "PASS";
    } else {
      return result;
    }
  }
  
  String scoutBaseOnlyAtABCDStarports(){
    Boolean pass = true;
    String result = "";
    for (System s : subs.systems.values()){
      if (s.occupied){
        if (s.scoutBase){
          if (s.uwp.starport == 'E' || s.uwp.starport == 'X'){
            result += "FAIL : " + s.name + " " + s.scoutBase + " " + s.uwp.starport + "\n";
          }
        }
      }
    }
    
    println("Scout Base only at ABCD Starports");
    if (pass){
      return "PASS";
    } else {
      return result;
    }
  }
  
  String noRoutesToRedZones(){
    Boolean pass = true;
    String result = "";
    for (System s : subs.systems.values()){
      if (s.occupied){
        if (ruleset.supportsTravelZones()){
          if (((System_CT81)s).travelZone.equals("Red") && s.routes.size() > 0){
            result += "FAIL : " + s.name + " " + ((System_CT81)s).travelZone + " " + s.routes.size() + "\n";
          }
        }
      }
    }
    
    println("No routes to Red Zones");
    if (pass){
      return "PASS";
    } else {
      return result;
    }
  }
}

// Moons/Rings should not themselves have satellites
// Planetoids/Rings always 000 for UWP Size/Atmo/Hydro
// Rings have 0 population
// Moons/Rings have the same orbital zone as their parent (barycenter)