class Route {
  System s1;
  System s2;
  int distance;
  
  Route(System _s1, System _s2){
    s1 = _s1;
    s2 = _s2;
    
    distance = s1.distanceToSystem(s2);
  }
  
  void show(){
    stroke(scheme.routes);
    strokeWeight(6);
    line(s1.hex.x, s1.hex.y, s2.hex.x, s2.hex.y);
  }
  
  String toString(){
    return "Jump " + distance + " : " + s1.name + " (" + s1.uwp.starport + ") " + " to " +
                                        s2.name + " (" + s1.uwp.starport + ")";
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    
    //json.set?
    
    // will be an issue here - this class holds references to System objects,
    // and can't directly stash that in JSON
    
    // should have a method to create a new route based on coordinates,
    // which then look up the reconstituted System objects on load
    
    // a couple related issues will need to be solved as part of that:
    //  - lookup of Systems via Coordinates - current ArrayList approach not helpful
    //  - comparison and identity of Coordinate objects
    //      does new Coordinate(3,4) == new Coordinate(3,4) ?
    
    return json;
  }
}