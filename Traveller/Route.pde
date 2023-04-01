class Route {
  System s1;
  System s2;
  int distance;
  
  Route(System _s1, System _s2){
    s1 = _s1;
    s1.addRoute(this);
    s2 = _s2;
    s2.addRoute(this);
    
    distance = s1.distanceToSystem(s2);
  }
  
  // to look up in the HashMap, we need the same object as the key
  // not just equivalent values, as you would get from JSON reconstitution
  // so this is a bit involved
  // 
  // Unfortunately there's a timing issue with the global Subsector object
  //  (which we need for the lookupCoordinate method). So this code moved
  //  into Subsector. May remove this ctor as it is not used currently.
  Route(JSONObject _json){
    Coordinate c1 = subs.lookupCoordinate(_json.getJSONObject("First Coordinate"));
    s1 = subs.systems.get(c1);
    
    Coordinate c2 = subs.lookupCoordinate(_json.getJSONObject("Second Coordinate"));
    s2 = subs.systems.get(c2);
        
    distance = s1.distanceToSystem(s2);
  }
  
  void show(){
    stroke(scheme.routes);
    strokeWeight(6);
    line(s1.hex.x, s1.hex.y, s2.hex.x, s2.hex.y);
  }

  void show(PGraphics _pg){
    _pg.stroke(scheme.routes);
    _pg.strokeWeight(6);
    _pg.line(s1.hex.x, s1.hex.y, s2.hex.x, s2.hex.y);
  }
  
  String toString(){
    return "Jump " + distance + " : " + s1.name + " (" + s1.uwp.starport + ") " + " to " +
                                        s2.name + " (" + s2.uwp.starport + ")";
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    json.setJSONObject("First Coordinate", s1.coord.asJSON());
    json.setString("First World", s1.name);   // for human readability
    json.setJSONObject("Second Coordinate", s2.coord.asJSON());
    json.setString("Second World", s2.name);
    return json;
  }
}