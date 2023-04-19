class Star extends Orbit {
  System parent;   // may want to rethink parent pointer for companions...
  
  char type;
  int typeRoll;

  int decimal;

  String size;  // Roman numerals - should we store as ints instead?
  int sizeRoll;
  
  Star[] companions;
  Star closeCompanion;
  
  Orbit[] orbits;
  
  Star(Boolean _primary, System _parent){
    parent = _parent;
    type = getType(_primary);  
    decimal = floor(random(10));
    size = getSize(_primary);
    if (size.equals("D")){ decimal = 0; }
  } 
  
  void createSatellites(){
    companions = new Star[getCompanionCount()];
    for (int i = 0; i < companions.length; i++){
      companions[i] = new Star(false, parent);
    }

    int maxCompanion = setCompanionOrbits();    
    int orbitCount = calculateMaxOrbits();

    orbits = createOrbits(orbitCount, maxCompanion);
    
    placeCompanions(orbitCount, maxCompanion);
    placeEmptyOrbits(orbitCount, maxCompanion);
  }
  
  Star(System _parent, String _s){
    parent = _parent;
    type = _s.charAt(0);
    decimal = int(_s.substring(1,2));
    size = _s.substring(2);
    
    // need to populate companions & orbits... may need to switch to JSON, string isn't enough...
  }
  
  void placeEmptyOrbits(int _orbitCount, int _maxCompanion){
    if (_maxCompanion - _orbitCount > 0){
      int startCount = max(0, _orbitCount);
      for (int i = startCount; i < orbits.length; i++){  
        if (orbits[i] == null){
          orbits[i] = new Empty();
        }
      }
    }
  }
  
  void placeCompanions(int _orbitCount, int _maxCompanion){   // args only used in debug output, can be removed once this stabilizes
    if (companions.length == 0){
      println("Orbits: " + orbits.length);
    } else {
      println("Orbits: " + orbits.length + " EMPTY: " + (_maxCompanion - _orbitCount));

      for (int i = 0; i < companions.length; i++){
        if (companions[i] != null){   // length calculations in following debug output will be off by one (per close companion...)
          println("Companion star number " + (i+1) + " of " + companions.length + " : Orbit = " + companions[i].orbitNumber + " : Usable Orbit Count = " + _orbitCount);
          orbits[companions[i].orbitNumber] = companions[i];
        } else {
          println("Close companion : Usable Orbit Count = " + _orbitCount);
        }
      }  
    }
  }
  
  Orbit[] createOrbits(int _orbitCount, int _maxCompanion){
    if (_orbitCount <= _maxCompanion){
      return new Orbit[_maxCompanion+1];
    } else {
      return new Orbit[_orbitCount];
    }    
  }
  
  int setCompanionOrbits(){
    int maxCompanion = 0;
    for (int i = 0; i < companions.length; i++){
      int modifier = 4 * (i);
      println("Assessing companion star: " + companions[i] + " modifier: +" + modifier);
      int dieThrow = twoDice() + modifier;
      int result = 0;
      if (dieThrow < 4  ){ result = 0; }  // actually "Close" - not the same as Orbit 0, how to represent?
      if (dieThrow == 4 ){ result = 1; }
      if (dieThrow == 5 ){ result = 2; }
      if (dieThrow == 6 ){ result = 3; }
      if (dieThrow == 7 ){ result = 4 + oneDie(); }
      if (dieThrow == 8 ){ result = 5 + oneDie(); }
      if (dieThrow == 9 ){ result = 6 + oneDie(); }
      if (dieThrow == 10){ result = 7 + oneDie(); }
      if (dieThrow == 11){ result = 8 + oneDie(); }
      if (dieThrow >= 12){               // "Far" - should convert this to an orbit number 
        int distance = 1000 * oneDie();
        if (distance == 1000                    ){ result = 14; }
        if (distance == 2000                    ){ result = 15; }
        if (distance == 3000 || distance == 4000){ result = 16; }
        if (distance >= 5000                    ){ result = 17; } // from tables on Scouts p.46 - should derive the formula instead
                                                                  // or calculate "Far" in terms of orbit number to begin with
      }
      if (result > maxCompanion){ maxCompanion = result; }
      
      if (result == 0){
        println("Companion in CLOSE orbit");
        companions[i].orbitNumber = result; 
        closeCompanion = companions[i];
        companions[i] = null;     // should shift to an ArrayList so we can remove properly... try the kludge first
      } else {
        println("Companion in orbit: " + result);
        companions[i].orbitNumber = result;
      }
      // need to classify Close & Far
      // need to screen orbits inside Primary
      // need to check for companions on Far results
      // need to handle two companions landing in same orbit
    }
    return maxCompanion;
  }
  
  char getType(Boolean _primary){
    int dieThrow = twoDice();
    if (_primary){
      typeRoll = dieThrow;
      if (dieThrow == 2               ){ return 'A'; }
      if (dieThrow > 2 && dieThrow < 8){ return 'M'; }
      if (dieThrow == 8               ){ return 'K'; }
      if (dieThrow == 9               ){ return 'G'; }
      if (dieThrow > 9                ){ return 'F'; }
      return 'X';
    } else {
      typeRoll = 0;
      dieThrow += ((System_ScoutsEx)parent).primary.typeRoll;
      if (dieThrow == 2                 ){ return 'A'; }
      if (dieThrow == 3 || dieThrow == 4){ return 'F'; }
      if (dieThrow == 5 || dieThrow == 6){ return 'G'; }
      if (dieThrow == 7 || dieThrow == 8){ return 'K'; }
      if (dieThrow > 8                  ){ return 'M'; }
      return 'X';
    }
  }
  
  String getSize(Boolean _primary){
    int dieThrow = twoDice();
    if (_primary){
      sizeRoll = dieThrow;
      if (dieThrow == 2                ){ return "II";  }
      if (dieThrow == 3                ){ return "III"; }
      if (dieThrow == 4                ){ 
        if ((type == 'K' && decimal > 4) || type == 'M'){
          return "V";
        } else {
          return "IV";
        }
      }
      if (dieThrow > 4 && dieThrow < 11){ return "V";   }
      if (dieThrow == 11               ){
        if (type == 'B' || type == 'A' || (type == 'F' && decimal < 5)){
          return "V";
        } else {
          return "VI";
        }
      }
      if (dieThrow == 12               ){ return "D";   }
      return "X";
    } else {
      sizeRoll = 0;
      dieThrow += ((System_ScoutsEx)parent).primary.sizeRoll;
      if (dieThrow == 2                 ){ return "II";  }
      if (dieThrow == 3                 ){ return "III"; }
      if (dieThrow == 4                 ){ 
        if ((type == 'K' && decimal > 4) || type == 'M'){
          return "V";
        } else {
          return "IV";
        }  
      }
      if (dieThrow == 5 || dieThrow == 6){ return "D";   }
      if (dieThrow == 7 || dieThrow == 8){ return "V";   }
      if (dieThrow == 9                 ){ 
        if (type == 'B' || type == 'A' || (type == 'F' && decimal < 5)){
          return "V";
        } else {
          return "VI";
        }          
      }
      if (dieThrow > 9                  ){ return "D";   }
      return "X";
    }
  }
  
  int getCompanionCount(){
    int dieThrow = twoDice();
    if (dieThrow < 8){ return 0; }
    if (dieThrow > 7 && dieThrow < 12){ return 1; }
    if (dieThrow == 12){ return 2; }
    return 0;
  }

  int calculateMaxOrbits(){
    int modifier = 0;
    if (size.equals("II") ){ modifier += 8; }  // rules include Ia/Ib supergiants here, but no means to generate them - omitting
    if (size.equals("III")){ modifier += 4; }
    if (type == 'M'       ){ modifier -= 4; }
    if (type == 'K'       ){ modifier -= 2; }

    int result = twoDice() + modifier; 
    if (result < 1){ 
      return 0; 
    } else {
      return result;
    }
  }  
  
  String toString(){
    return str(type) + decimal + size; // white dwarfs follow a different convention, should adjust here and in parser ctor above
  }
}