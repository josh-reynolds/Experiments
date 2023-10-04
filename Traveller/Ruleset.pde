class Ruleset {
  String name;
  int current = 0;
  String[] rules = {"CT77", "CT81", "Scouts (Extended)", "MegaTraveller (Extended)"};

  // would like to handle creation via a static factory method,
  // but Processing's inner class approach won't allow that

  Ruleset(){
    name = rules[current];
  }
  
  // used when loading from JSON
  Ruleset(String _rules){
    for (int i = 0; i < rules.length; i++){
      if (rules[i].equals(_rules)){ current = i; }
    }
    name = rules[current];
  }
  
  void next(){
    current++;
    current %= rules.length;
    name = rules[current];
  }
  
  Boolean supportsTravelZones(){
    switch(name) {
      case "CT77":
        return false;
      case "CT81":
      case "Scouts (Extended)":
      case "MegaTraveller (Extended)":
        return true;
      default:
        return false;
    }
  }
  
  Boolean supportsStars(){
    switch(name) {
      case "CT77":
      case "CT81":
        return false;
      case "Scouts (Extended)":
      case "MegaTraveller (Extended)":
        return true;
      default:
        return false;
    }
  }
  
  Boolean supportsDensity(){
    switch(name) {
      case "CT77":
      case "CT81":
        return false;
      case "Scouts (Extended)":
      case "MegaTraveller (Extended)":
        return true;
      default:
        return false;
    }
  }

  Boolean supportsTraffic(){
    switch(name) {
      case "CT77":
      case "CT81":
      case "Scouts (Extended)":
        return false;
      case "MegaTraveller (Extended)":
        return true;
      default:
        return false;
    }
  }
  
  System newSystem(Coordinate _coord, Boolean _occupied){
    switch(name) {
      case "CT77":
        return new System(_coord, _occupied);
      case "CT81":
        return new System_CT81(_coord, _occupied);
      case "Scouts (Extended)":
        return new System_ScoutsEx(_coord, _occupied);
      case "MegaTraveller (Extended)":
        return new System_MT(_coord, _occupied);
      default:
        return new System(_coord, _occupied);
    }
  }
  
  Subsector newSubsector(){
    switch(name) {
      case "CT77":
      case "CT81":
      case "Scouts (Extended)":
        return new Subsector();
      case "MegaTraveller (Extended)":
        return new Subsector_MT();
      default:                    
        return new Subsector();
    }
  }
  
  System newSystem(JSONObject _json){
    // TO_DO: maybe we should detect ruleset from a JSON field... or think about polymorphism here
    switch(name) {
      case "CT77":
        return new System(_json);
      case "CT81":
        return new System_CT81(_json);
      case "Scouts (Extended)":
        return new System_ScoutsEx(_json);
      case "MegaTraveller (Extended)":
        return new System_ScoutsEx(_json);       // TO_DO: swap as we build up the correct classes
      default:                                   // we haven't implemented fromJSON yet for MT
        return new System(_json);
    }
  }
  
  OrbitBuilder newOrbitBuilder(){
    switch(name) {
      case "CT77":
      case "CT81":
        println("Orbits not supported");
        return new OrbitBuilder();               // keeping the compiler happy - throw an exception instead?
      case "Scouts (Extended)":
        return new OrbitBuilder();
      case "MegaTraveller (Extended)":
        return new OrbitBuilder_MT();
      default:
        return new OrbitBuilder();
    }
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    switch(name) {            
      case "Scouts (Extended)":
        return new UWP_ScoutsEx();        // throw an exception?
      case "MegaTraveller (Extended)":
        return new UWP_MT();              // throw an exception?     
      case "CT81":     
      case "CT77":
      default:
        return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
    }
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    switch(name) {            
      case "Scouts (Extended)":
        return new UWP_ScoutsEx(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
      case "MegaTraveller (Extended)":
        return new UWP_MT(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
      case "CT81":     
      case "CT77":
      default:
        return new UWP_ScoutsEx();        // throw an exception?
    }                                     // need to be Scouts to satisfy compiler
  }
  
  UWPBuilder newUWPBuilder(){ 
    switch(name) {            
      case "CT81":            
        return new UWPBuilder_CT81();
      case "Scouts (Extended)":
        return new UWPBuilder_ScoutsEx();
      case "MegaTraveller (Extended)":
        return new UWPBuilder_MT();
      case "CT77":
      default:
        return new UWPBuilder();
    }    
  }
  
  // primary stars
  Star newStar(System _parent){
    switch(name) {
      case "CT77":
      case "CT81":
        println("Stars not supported");
        return new Star(_parent);               // keeping the compiler happy - throw an exception instead?
      case "Scouts (Extended)":
        return new Star(_parent);
      case "MegaTraveller (Extended)":
        return new Star_MT(_parent);
      default:
        return new Star(_parent);
    }
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    switch(name) {
      case "CT77":
      case "CT81":
        println("Stars not supported");
        return new Star(_barycenter, _orbit, _zone, _parent);               // keeping the compiler happy - throw an exception instead?
      case "Scouts (Extended)":
        return new Star(_barycenter, _orbit, _zone, _parent);
      case "MegaTraveller (Extended)":
        return new Star_MT(_barycenter, _orbit, _zone, _parent);
      default:
        return new Star(_barycenter, _orbit, _zone, _parent);
    }
  }
  
  TradeClass newTradeClass(UWP _uwp){
    switch(name) {
      case "CT77":
        return new TradeClass(_uwp);
      case "CT81":
        return new TradeClass_CT81(_uwp);
      case "Scouts (Extended)":
        return new TradeClass_ScoutsEx(_uwp);
      case "MegaTraveller (Extended)":
        return new TradeClass_MT(_uwp);
      default:
        return new TradeClass(_uwp);
    }
  }
}

class Ruleset_CT77 extends Ruleset {
  String name;
  //int current = 0;
  //String[] rules = {"CT77", "CT81", "Scouts (Extended)", "MegaTraveller (Extended)"};

  Ruleset_CT77(){ name = "CT77"; }
  
  // used when loading from JSON
  //Ruleset_CT77(String _rules){
  //  for (int i = 0; i < rules.length; i++){
  //    if (rules[i].equals(_rules)){ current = i; }
  //  }
  //  name = rules[current];
  //}
  
  //Ruleset next(){
  //  return new Ruleset_CT81();
  //}
  
  Boolean supportsTravelZones(){ return false; }
  Boolean supportsStars()      { return false; }
  Boolean supportsDensity()    { return false; }
  Boolean supportsTraffic()    { return false; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){ 
    return new System(_coord, _occupied); 
  }
  
  Subsector newSubsector(){ 
    return new Subsector(); 
  }
  
  System newSystem(JSONObject _json){ 
    return new System(_json); 
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder(); 
  }
  
  TradeClass newTradeClass(UWP _uwp){ 
    return new TradeClass(_uwp); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    println("Orbits not supported");
    return new OrbitBuilder();               // keeping the compiler happy - throw an exception instead?
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_ScoutsEx();        // throw an exception?
  }
  
  // primary stars
  Star newStar(System _parent){
    println("Stars not supported");
    return new Star(_parent);               // keeping the compiler happy - throw an exception instead?
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    println("Stars not supported");
    return new Star(_barycenter, _orbit, _zone, _parent);               // keeping the compiler happy - throw an exception instead?
  }
}