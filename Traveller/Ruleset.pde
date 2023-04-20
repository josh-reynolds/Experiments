class Ruleset {
  String rules;  // default is CT77
  
  Ruleset(String _rules){
    rules = _rules;
  }
  
  Boolean supportsTravelZones(){
    switch(rules) {
      case "CT77":
        return false;
      case "CT81":
      case "Scouts (Extended)":
        return true;
      default:
        return false;
    }
  }
  
  System newSystem(Coordinate _coord){
    switch(rules) {
      case "CT77":
        return new System(_coord);
      case "CT81":
        return new System_CT81(_coord);
      case "Scouts (Extended)":
        return new System_ScoutsEx(_coord);
      default:
        return new System(_coord);
    }
  }
  
  System newSystem(JSONObject _json){
    // TO_DO: maybe we should detect ruleset from a JSON field... or think about polymorphism here
    switch(rules) {
      case "CT77":
        return new System(_json);
      case "CT81":
        return new System_CT81(_json);
      case "Scouts (Extended)":
        return new System_ScoutsEx(_json);
      default:
        return new System(_json);
    }
  }
}