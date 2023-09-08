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
  
  System newSystem(Coordinate _coord, Float _density){
    switch(name) {
      case "CT77":
        return new System(_coord, _density);
      case "CT81":
        return new System_CT81(_coord, _density);
      case "Scouts (Extended)":
        return new System_ScoutsEx(_coord, _density);
      case "MegaTraveller (Extended)":
        return new System_MT(_coord, _density);
      default:
        return new System(_coord, _density);
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
      default:
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
}