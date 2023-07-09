class Ruleset {
  String name;
  int currentRules = 0;
  String[] rules = {"CT77", "CT81", "Scouts (Extended)", "MegaTraveller (Extended)"};

  // would like to handle creation via a static factory method,
  // but Processing's inner class approach won't allow that

  Ruleset(){
    name = rules[currentRules];
  }
  
  Ruleset(String _rules){
    for (int i = 0; i < rules.length; i++){
      if (rules[i].equals(_rules)){ currentRules = i; }
    }
    name = rules[currentRules];
  }
  
  Ruleset(int _current){
    currentRules = _current;
    name = rules[currentRules];
  }
  
  void next(){
    currentRules++;
    currentRules %= rules.length;
    ruleset = new Ruleset(currentRules);
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
        return new System_ScoutsEx(_coord, _density);   // TO_DO: swap as we build up the correct classes
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
}