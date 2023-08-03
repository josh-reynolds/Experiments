class Ship {
 String name;
 System location;
 int range;
 Subsector sub;
 
 Ship(String _name, int _range, Subsector _sub){
   name = _name;
   range = _range;
   //sub = _sub;
   //location = randomStart(_sub);                // in current creation order, sub doesn't exist yet - rework
 }
 
 String toString(){
   return name + " : " + location;
 }
 
 System randomStart(Subsector _sub){
   ArrayList<System> occupiedSystems = new ArrayList();
   
   for (System s : _sub.systems.values()){
     if (s.occupied){ occupiedSystems.add(s); }
   }
   
   int systemCount = occupiedSystems.size();
   int choice = floor(random(0, systemCount));
   
   return occupiedSystems.get(choice);
 }
 
 ArrayList<System> withinRange(Subsector _sub){
   ArrayList<System> systems = new ArrayList();
   
   for (System s : _sub.systems.values()){
     int distance = s.coord.distanceTo(location.coord);
     if (distance <= range && distance > 0 && s.occupied){
       systems.add(s);
     }
   }
   
   return systems;
 }
 
 void show(){           // very rudimentary for now
   strokeWeight(2);
   stroke(0,0,255);     // TO_DO: get into ColorScheme
   fill(0,0,255,75);    // this one too...
   ellipse(location.hex.x, location.hex.y, hexRadius, hexRadius); 
 }
}