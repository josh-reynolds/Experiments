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
  
  String summary(){
    String output = name + " contains ";
    
    int worldCount = 0;
    long totalPop = 0;
    ArrayList<String> highestPop = new ArrayList<String>();
    int maxPop = 0;
    ArrayList<String> highestTech = new ArrayList<String>();
    int maxTech = 0;
    String maxTechString = "";
    for (System s : systems.values()){
      if (s.occupied){ 
        worldCount++;
        totalPop += pow(10, s.uwp.pop);

        if (s.uwp.pop == maxPop){
          highestPop.add(s.name);
        }
        if (s.uwp.pop > maxPop){
          maxPop = s.uwp.pop;
          highestPop = new ArrayList<String>();
          highestPop.add(s.name);
        }
        
        if (s.uwp.tech == maxTech){
          highestTech.add(s.name);
        }
        if (s.uwp.tech > maxTech){
          maxTech = s.uwp.tech;
          maxTechString = s.uwp.modifiedHexChar(maxTech);
          highestTech = new ArrayList<String>();
          highestTech.add(s.name);
        }
      }
    }
    
    float million = 1000000;
    float billion = 1000000000;
    String popString;
    if (floor(totalPop/billion) > 0){
      popString = nf(totalPop/billion, 0, 2) + " billion";
    } else if (floor(totalPop/million) > 0){
      popString = nf(totalPop/million, 0, 2) + " million";
    } else {
      popString = nf(totalPop/1000, 0, 2) + " thousand";
    }
    
    output += worldCount + " worlds with a population of " + popString + ". "; 
    output += "The highest population is " + hex(maxPop, 1) + " at ";
    
    if (highestPop.size() == 1){
      output += highestPop.get(0) + ";";
    } else {
      for (int i = 0; i < highestPop.size()-2; i++){
        output += highestPop.get(i) + ", ";
      }
      output += highestPop.get(highestPop.size()-2) + " and ";
      output += highestPop.get(highestPop.size()-1) + ";";
    }
    
    output += " the highest tech level is " + maxTechString + ", at ";
    
    if (highestTech.size() == 1){
      output += highestTech.get(0) + ".";
    } else {
      for (int i = 0; i < highestTech.size()-2; i++){
        output += highestTech.get(i) + ", ";
      }
      output += highestTech.get(highestTech.size()-2) + " and ";
      output += highestTech.get(highestTech.size()-1) + ".";
    }
    
    return output;
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
      
      for (int j = i+1; j < coords.length; j++){
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