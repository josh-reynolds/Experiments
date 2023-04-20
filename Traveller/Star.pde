class Star extends Orbit {
  System parent;   // TO_DO: may want to rethink parent pointer for companions...
  Boolean primary;
  
  char type;
  int typeRoll;

  int decimal;

  String size;  // TO_DO: Roman numerals - should we store as ints instead?
  int sizeRoll;
  
  ArrayList<Star> companions;
  Star closeCompanion;
  
  Orbit[] orbits;
  
  Star(Boolean _primary, System _parent){
    primary = _primary;
    parent = _parent;
    type = getType(_primary);  
    decimal = floor(random(10));
    size = getSize(_primary);
    if (size.equals("D")){ decimal = 0; }
  } 

  Star(Boolean _primary, System _parent, String _s){               // TO_DO: deprecate this ctor
    primary = _primary;
    parent = _parent;
    generateClass(_s);
  }
  
  Star(Boolean _primary, System _parent, JSONObject _json){
    primary = _primary;
    parent = _parent;
    companions = new ArrayList<Star>();
    
    generateClass(_json.getString("Class"));
    
    if (primary){                                                   // TO_DO: at some point we'll add children to companions, then remove this test
      if (!_json.isNull("Close Companion")){
        closeCompanion = new Star(false, parent, _json.getJSONObject("Close Companion")); 
      }
      
      if (!_json.isNull("Companions")){    
        JSONArray comps = _json.getJSONArray("Companions");
        for (int i = 0; i < comps.size(); i++){
          companions.add(new Star(false, parent, comps.getJSONObject(i)));
        }
      }
      
      if (!_json.isNull("Orbits")){
        JSONArray ob = _json.getJSONArray("Orbits");
        orbits = new Orbit[ob.size()];
        for (int i = 0; i < ob.size(); i++){                         // TO_DO: very fragile, will want to push out to subclasses and stop relying on string parsing
          if (ob.getString(i).equals("null")){                       //          (some redundancy w/ companion list if we put JSONObjects here, though...) 
            orbits[i] = null;                                        // TO_DO: will go away once we populate all orbit variants 
          } else if (ob.getString(i).equals("Empty")){ 
            orbits[i] = new Empty();                                 // TO_DO: need a ctor that takes orbit number to comply with inherited interface 
          } else {
            orbits[i] = new Star(false, parent, ob.getString(i));    // TO_DO: conflict/duplication with companion list - deprecate and rework this
          }
        }
      }
    } else {
      orbitNumber = _json.getInt("Orbit");  // TO_DO: currently null for primary - all companions have a value
    }

  }
  
  void generateClass(String _s){
    type = _s.charAt(0);
    decimal = int(_s.substring(1,2));
    size = _s.substring(2);
  }
  
  void createSatellites(){
    companions = new ArrayList<Star>();
    int compCount = getCompanionCount();
    for (int i = 0; i < compCount; i++){
      companions.add(new Star(false, parent));
    }

    int maxCompanion = setCompanionOrbits();    
    int orbitCount = calculateMaxOrbits();

    orbits = createOrbits(orbitCount, maxCompanion);
    
    placeCompanions(orbitCount, maxCompanion);
    placeEmptyOrbits(orbitCount, maxCompanion);
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
  
  void placeCompanions(int _orbitCount, int _maxCompanion){   // TO_DO: args only used in debug output, can be removed once this stabilizes
    if (companions.size() == 0){
      println("Orbits: " + orbits.length);
    } else {
      println("Orbits: " + orbits.length + " EMPTY: " + (_maxCompanion - _orbitCount));
      for (int i = 0; i < companions.size(); i++){
        println("Companion star number " + (i+1) + " of " + companions.size() + " : Orbit = " + companions.get(i).orbitNumber + " : Usable Orbit Count = " + _orbitCount);
        orbits[companions.get(i).orbitNumber] = companions.get(i);
      }
      if (closeCompanion != null){
        println("Close companion : Usable Orbit Count = " + _orbitCount);
      }
    }
  }
  
  Orbit[] createOrbits(int _orbitCount, int _maxCompanion){
    if (_orbitCount <= _maxCompanion){
      return new Orbit[_maxCompanion+1];   // TO_DO: off by one if there is a CLOSE companion or if both orbitCount + maxCompanion are zero
    } else {
      return new Orbit[_orbitCount];
    }    
  }
  
  int setCompanionOrbits(){
    int maxCompanion = 0;
    for (int i = 0; i < companions.size(); i++){
      int modifier = 4 * (i);
      println("Assessing companion star: " + companions.get(i) + " modifier: +" + modifier);
      int dieThrow = twoDice() + modifier;
      int result = 0;
      if (dieThrow < 4  ){ result = 0; }  // actually "Close" - not truly Orbit 0 - system will not place companions there
      if (dieThrow == 4 ){ result = 1; }
      if (dieThrow == 5 ){ result = 2; }
      if (dieThrow == 6 ){ result = 3; }
      if (dieThrow == 7 ){ result = 4 + oneDie(); }
      if (dieThrow == 8 ){ result = 5 + oneDie(); }
      if (dieThrow == 9 ){ result = 6 + oneDie(); }
      if (dieThrow == 10){ result = 7 + oneDie(); }
      if (dieThrow == 11){ result = 8 + oneDie(); }
      if (dieThrow >= 12){               // TO_DO: "Far" - should convert this to an orbit number 
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
        closeCompanion = companions.get(i);
        companions.remove(i);
        closeCompanion.orbitNumber = result;
      } else {
        println("Companion in orbit: " + result);
        companions.get(i).orbitNumber = result;
      }
      // TO_DO: need to classify Close & Far
      // TO_DO: need to screen orbits inside Primary
      // TO_DO: need to check for companions on Far results
      // TO_DO: need to handle two companions landing in same orbit
    }
    return maxCompanion;   // TO_DO: off by one in the CLOSE Companion case
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
    return str(type) + decimal + size; // TO_DO: white dwarfs follow a different convention, should adjust here and in parser ctor above
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    
    json.setString("Class", this.toString());
    
    if (primary){  
      if (closeCompanion != null){
        json.setJSONObject("Close Companion", closeCompanion.asJSON());
      }
      
      if (companions.size() > 0){
        JSONArray companionList = new JSONArray();
        for (int i = 0; i < companions.size(); i++){
          companionList.setJSONObject(i, companions.get(i).asJSON());
        }
        json.setJSONArray("Companions", companionList);
      }
      
      if (orbits.length > 0){
        JSONArray orbitsList = new JSONArray();
        for (int i = 0; i < orbits.length; i++){
          if (orbits[i] != null){               // TO_DO: eventually all orbits should be populated (only null during creation) and we can remove this clause
            orbitsList.setString(i, orbits[i].toString());   // TO_DO: for now only use Star JSON in companion lists above, redundant here
          } else {
            orbitsList.setString(i, "null");
          }
        }
        json.setJSONArray("Orbits", orbitsList);
      }
    } else {
      json.setInt("Orbit", orbitNumber);
    }
    
    return json;
  }
}