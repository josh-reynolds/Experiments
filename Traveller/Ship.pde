class Ship {
 String name;
 System location;
 
 Ship(String _name, System _location){
   name = _name;
   location = _location;
 }
 
 String toString(){
   return name + " : " + location;
 }
 
 System randomStart(Subsector _sub){
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