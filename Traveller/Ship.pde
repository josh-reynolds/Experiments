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
 
 System randomStart(Subsector _sub){               // current naive implementation can return EMPTY systems
   int systemCount = _sub.systems.values().size();
   int choice = floor(random(0, systemCount));
   
   int counter = 0;
   for (System s : _sub.systems.values()){
     if (counter == choice){ return s; }
     counter++;
   }
   
   return null;
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
}