class Ruleset {
  String rules;  // default is CT77
  
  Ruleset(String _rules){
    rules = _rules;
  }
  
  System newSystem(Coordinate _coord){
    switch(rules) {
      case "CT77":
        return new System(_coord);
      case "CT81":
        return new System_CT81(_coord);
      default:
        return new System(_coord);
    }
  }
  
  System newSystem(JSONObject _json){
    // maybe we should detect ruleset from
    // a JSON field...
    switch(rules) {
      case "CT77":
        return new System(_json);
      case "CT81":
        return new System_CT81(_json);
      default:
        return new System(_json);
    }
  }
}