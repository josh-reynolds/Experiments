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
}