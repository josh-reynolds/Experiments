class Subsector{
  String name;
  
  ArrayList<System> systems;
  int vertCount = 10;
  int horzCount = 8;
  
  ArrayList<Route> routes;
  
  Subsector(){
    name = "Subsector_" + lines[floor(random(lines.length))];
      
    systems = new ArrayList<System>();
    routes = new ArrayList<Route>();
    
    for (int j = 1; j <= horzCount; j++){
      for (int i = 1; i <= vertCount; i++){      
        Coordinate coord = new Coordinate(j, i);
        systems.add(new System(coord));
      }
    }
    
    calculateRoutes();
  }
  
  JSONObject asJSON(){
    JSONArray systemList = new JSONArray();    
    for (int i = 0; i < systems.size(); i++){
      System s = systems.get(i);    
      systemList.setJSONObject(i, s.asJSON());
    }

    JSONArray routeList = new JSONArray();
    for (int i = 0; i < routes.size(); i++){
      Route r = routes.get(i);
      routeList.setJSONObject(i, r.asJSON());
    }

    JSONObject json = new JSONObject();
    json.setJSONArray("Systems", systemList);
    json.setJSONArray("Routes", routeList);
    
    return json;
  }
  
  void calculateRoutes(){
    for (int i = 0; i < systems.size(); i++){
      System candidate = systems.get(i);
      if (!candidate.occupied || candidate.uwp.starport == 'X'){ continue; }
      
      for (int j = i + 1; j < systems.size(); j++){
        System target = systems.get(j);
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