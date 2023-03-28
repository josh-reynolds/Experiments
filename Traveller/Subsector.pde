class Subsector{
  String name;
  
  LinkedHashMap<Coordinate, System> systems;
  int vertCount = 10;
  int horzCount = 8;
  
  ArrayList<Route> routes;
  
  Subsector(){
    name = "Subsector_" + lines[floor(random(lines.length))];
    
    systems = new LinkedHashMap<Coordinate, System>();
    routes = new ArrayList<Route>();
    
    for (int j = 1; j <= horzCount; j++){
      for (int i = 1; i <= vertCount; i++){      
        Coordinate coord = new Coordinate(j, i);
        systems.put(coord, new System(coord));
      }
    }
    
    calculateRoutes();
  }
  
  Subsector(JSONObject _json){
    name = _json.getString("Subsector Name");
    
    systems = new LinkedHashMap<Coordinate, System>();
    routes = new ArrayList<Route>();
    
    JSONArray systemList = _json.getJSONArray("Systems");
    for (int i = 0; i < systemList.size(); i++){
      System s = new System(systemList.getJSONObject(i));
      systems.put(s.coord, s);
    }    
    
    JSONArray routeList = _json.getJSONArray("Routes");
    for (int i = 0; i < routeList.size(); i++){
      JSONObject rt = routeList.getJSONObject(i);
      
      Coordinate c1 = lookupCoordinate(rt.getJSONObject("First Coordinate"));
      System s1 = systems.get(c1);
      
      Coordinate c2 = lookupCoordinate(rt.getJSONObject("Second Coordinate"));
      System s2 = systems.get(c2);

      Route r = new Route(s1, s2);
      routes.add(r);
    }
  }
  
  JSONObject asJSON(){
    JSONArray systemList = new JSONArray();    
    
    int counter = 0;
    for (Map.Entry me : systems.entrySet()){
      System s = (System)me.getValue();
      systemList.setJSONObject(counter, s.asJSON());
      counter++;
    }

    JSONArray routeList = new JSONArray();
    for (int i = 0; i < routes.size(); i++){
      Route r = routes.get(i);
      routeList.setJSONObject(i, r.asJSON());
    }

    JSONObject json = new JSONObject();
    json.setString("Subsector Name", name);
    json.setJSONArray("Systems", systemList);
    json.setJSONArray("Routes", routeList);
    
    return json;
  }
  
  Coordinate lookupCoordinate(JSONObject _json){
    Coordinate test = new Coordinate(_json);
    Coordinate[] coords = systems.keySet().toArray(new Coordinate[0]);
    
    for (int i = 0; i < coords.length; i++){
      Coordinate candidate = coords[i]; 
      if (candidate.equals(test)){ return candidate; } 
    }
    return null;
  }
  
  void calculateRoutes(){
    Coordinate[] coords = systems.keySet().toArray(new Coordinate[0]);

    for (int i = 0; i < coords.length; i++){
      System candidate = systems.get(coords[i]);
      if (!candidate.occupied || candidate.uwp.starport == 'X'){ continue; }
      
      for (int j = 0; j < coords.length; j++){
        System target = systems.get(coords[j]);
        if (!target.occupied || target.uwp.starport == 'X'){ continue; }
        
        int dist = candidate.distanceToSystem(target);  
        if (dist > 4){ continue; }
        
        char starportA = candidate.uwp.starport;
        char starportB = target.uwp.starport;
        String pair;
        if (starportA <= starportB){ 
          pair = str(starportA) + str(starportB); 
        } else {
          pair = str(starportB) + str(starportA);
        }
  
        int roll = oneDie();
  
        // transcription of the table on p.2 of Book 3 (1st edition)
        // probably a clever way to make this shorter, refactoring opportunity
        // later perhaps
        if (pair.equals("AA")){
          if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 2){ routes.add(new Route(candidate, target)); }
          if (dist == 3 && roll >= 4){ routes.add(new Route(candidate, target)); }
          if (dist == 4 && roll >= 5){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("AB")){
          if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 3){ routes.add(new Route(candidate, target)); }
          if (dist == 3 && roll >= 4){ routes.add(new Route(candidate, target)); }
          if (dist == 4 && roll >= 5){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("AC")){
          if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 4){ routes.add(new Route(candidate, target)); }
          if (dist == 3 && roll >= 6){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("AD")){
          if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 5){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("AE")){
          if (dist == 1 && roll >= 2){ routes.add(new Route(candidate, target)); }
        }
  
        if (pair.equals("BB")){
          if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 3){ routes.add(new Route(candidate, target)); }
          if (dist == 3 && roll >= 4){ routes.add(new Route(candidate, target)); }
          if (dist == 4 && roll >= 6){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("BC")){
          if (dist == 1 && roll >= 2){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 4){ routes.add(new Route(candidate, target)); }
          if (dist == 3 && roll >= 6){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("BD")){
          if (dist == 1 && roll >= 3){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 6){ routes.add(new Route(candidate, target)); }  
        }
        if (pair.equals("BE")){
          if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
        }
        
        if (pair.equals("CC")){
          if (dist == 1 && roll >= 3){ routes.add(new Route(candidate, target)); }
          if (dist == 2 && roll >= 6){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("CD")){
          if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("CE")){
          if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
        }
        
        if (pair.equals("DD")){
          if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
        }
        if (pair.equals("DE")){
          if (dist == 1 && roll >= 5){ routes.add(new Route(candidate, target)); }
        }
        
        if (pair.equals("EE")){
          if (dist == 1 && roll >= 6){ routes.add(new Route(candidate, target)); }
        }
      }
    }
  }
}