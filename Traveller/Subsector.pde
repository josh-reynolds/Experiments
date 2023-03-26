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
  }
}