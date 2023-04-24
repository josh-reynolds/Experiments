class Star extends Orbit {
  System parent;   // TO_DO: may want to rethink parent pointer for companions...
  Boolean primary;
  
  char type;
  int typeRoll;

  int decimal;

  int size;
  int sizeRoll;
  
  ArrayList<Star> companions;
  Star closeCompanion;
  
  Orbit[] orbits;
  
  Star(Boolean _primary, System _parent){
    primary = _primary;
    parent = _parent;
    companions = new ArrayList<Star>();
    
    type = generateType();  
    decimal = floor(random(10));
    size = generateSize();
    if (size == 7){ decimal = 0; }
  } 

  Star(Boolean _primary, System _parent, String _s){               // TO_DO: deprecate this ctor
    primary = _primary;
    parent = _parent;
    companions = new ArrayList<Star>();
    
    classFromString(_s);
  }
  
  Star(Boolean _primary, System _parent, JSONObject _json){
    primary = _primary;
    parent = _parent;
    companions = new ArrayList<Star>();
    
    classFromString(_json.getString("Class"));

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
          orbits[i] = new Empty(i); 
        } else {
          orbits[i] = new Star(false, parent, ob.getString(i));    // TO_DO: conflict/duplication with companion list - deprecate and rework this
        }
      }
    }
    
    if (!primary){
      orbitNumber = _json.getInt("Orbit");  // TO_DO: currently null for primary - all companions have a value
    }
  }
  
  void classFromString(String _s){
    char first = _s.charAt(0);
    if (first == 'D'){  // convention is different for White Dwarfs
      type = _s.charAt(1);
      decimal = 0;
      size = sizeFromString(str(first));
    } else {
      type = first;
      decimal = int(_s.substring(1,2));
      size = sizeFromString(_s.substring(2));
    }
  }
  
  // currently only called on primary
  // adjust so it can be called on companions
  // and sort out when/where to call (finish all primary orbits first?)
  void createSatellites(){
    int maxCompanion = 0;
    if (primary || orbitIsFar(orbitNumber)){       // TO_DO: these methods take modifiers for companions, need to wire that in
      int compCount = getCompanionCount();
      println(compCount + " companions");
      for (int i = 0; i < compCount; i++){
        companions.add(new Star(false, parent));
      }
      maxCompanion = setCompanionOrbits();    
    }  
      
    int orbitCount = calculateMaxOrbits();
    if (!primary){ orbitCount = constrain(orbitCount, 0, floor(orbitNumber/2)); }
    orbits = createOrbits(orbitCount, maxCompanion);
    
    placeCompanions(orbitCount, maxCompanion);    // may need to adjust the ordering of these method calls
    placeEmptyOrbits(orbitCount, maxCompanion);
    placeForbiddenOrbits();
    
    placeNullOrbits();    // TO_DO: probably temporary scaffolding to smooth addition of later elements
    
    for (Star c : companions){
      c.createSatellites();
    }
    
    placeZones();   // TO_DO: some orbits are still null at this point
                    // should this be a query instead of a field on Orbit?
                    // see above - introduced a null object as (temp?) workaround
  }
  
  void placeNullOrbits(){
    if (orbits.length > 0){
      for (int i = 0; i < orbits.length; i++){
        if (orbits[i] == null){
          orbits[i] = new Null(i);
        }
      }
    }
  }
  
  // TO_DO: currently only handles the companion case
  //  later rules can impose additional empty orbits, will extend this method
  void placeEmptyOrbits(int _orbitCount, int _maxCompanion){
    if (_maxCompanion - _orbitCount > 0){
      int startCount = max(0, _orbitCount);
      for (int i = startCount; i < orbits.length; i++){  
        if (orbits[i] == null){
          orbits[i] = new Empty(i);
        }
      }
    }
  }
  
  // may want to redo this as a query, and combine with the Forbidden orbit logic (same data source for both)
  // also 
  // - table has inconsistencies w.r.t. rows, having to guess at some values for orbit 0 esp.
  // - the system by RAW cannot generate supergiants (Ia/Ib) or O/B stars, so could omit that data
  // - special case for M9 not handled yet - all other decimal values round to 0/5 for all spectral classes except M
  void placeZones(){
    if (orbits.length > 0){
      println("Setting orbital zones for " + this);
      
      // data from Scouts pp. 29-31
      Table table = loadTable("OrbitalZones.csv", "header");  // probably want to load this as a global resource
      String classForLookup = "";
      if (size < 7){  // white dwarfs have a different naming convention, don't need to worry about decimal value
        int roundedDecimal  = floor(decimal/5) * 5;
        classForLookup = str(type) + roundedDecimal + sizeToString();  // duplication from to_string()
      } else {
        classForLookup = this.toString();
      }
            
      for (TableRow row : table.rows()){
        if (row.getString("Class").equals(classForLookup)){
          println("Found row " + classForLookup);
          for (Orbit o : orbits){
            o.orbitalZone = row.getString(str(o.orbitNumber));
          }
        }
      }
    }
  }
  
  // three cases:
  //  - DONE  orbit is inside star (have query method)
  //  - DONE  orbit is suppressed by nearby companion star
  //  - TO_DO   (Far companion case is unclear - in RAW, they don't have an orbit num so are not evaluated in this test)
  //  - TO_DO orbit is too hot to allow planets
  void placeForbiddenOrbits(){
    if (orbits.length > 0){
      for (int i = 0; i < orbits.length; i++){
        if ((orbitInsideStar(i) || maskedByCompanion(i)) &&
            isNullOrEmpty(i)){
          orbits[i] = new Forbidden(i);
        }
      }
    }
  }
  
  Boolean isNullOrEmpty(int _num){
    return (orbits[_num] == null ||
            orbits[_num].getClass().getSimpleName().equals("Empty"));
  }
  
  Boolean maskedByCompanion(int _orbitNum){
    if (companions.size() == 0){
      return false;
    } else {
      for (int i = 0; i < companions.size(); i++){
        int compOrbit = companions.get(i).orbitNumber;
        print(" Evaluating companion mask for " + companions.get(i) + " in orbit " + compOrbit +" against " + _orbitNum);
        
        // some ambiguity here from RAW (Scouts p.23)
        // rule states: Orbits closer to the primary than the companion's orbit must be numbered no more than half of the companion's orbit number (round fractions down)
        //              Orbits farther away than the companion must be numbered at least two greater than the companion's orbit number
        // examples state: in a system with a companion in orbit 2, orbit 0 is available and orbits 4 and higher are available             (why not orbit 1? half of 2)
        //                 in a system with a companion at orbit 5, orbits 0, 1 and 2 are available, and orbits 7 and higher are available (contrariwise, how is 2 OK? half of 5 rounded down is 2)
        // simplest is to assume first example is a typo, and orbit 1 should be available - then this is consistent - implementing this approach
        
        if (_orbitNum < compOrbit && _orbitNum > compOrbit/2 ){ println(" TRUE!"); return true; }
        if (_orbitNum == compOrbit                           ){ println(" TRUE!"); return true; } 
        if (_orbitNum > compOrbit && _orbitNum <= compOrbit+1){ println(" TRUE!"); return true; }
      }
      println(" FALSE"); return false;
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

  // Scouts includes data for Supergiants (Ia/Ib) but no means to generate randomly - leaving out
  // Tables are on pp. 29-31, implementing RAW
  // TO_DO: tables handle orbit 0 inconsistently, so this func is incomplete - need to derive additional data
  Boolean orbitInsideStar(int _num){
    if (size == 2){
      if (type == 'K'){
        if (decimal < 5 ){ return false;     }
        if (decimal >= 5){ return _num <= 1; }
      }
      if (type == 'M'){
        if (decimal < 5 ){ return _num <= 3; }
        if (decimal >= 5){ return _num <= 5; }
      }
      return false;
    }
    if (size == 3){
      if (type != 'M'                 ){ return false; }
      if (decimal < 5                 ){ return false; }
      if (decimal >= 5 && decimal <= 7){ return _num <= 3; }
      if (decimal > 7                 ){ return _num <= 4; }
    }
    return false;
  }
  
  Orbit[] createOrbits(int _orbitCount, int _maxCompanion){
    if (_orbitCount <= _maxCompanion){
      return new Orbit[_maxCompanion+1];   // TO_DO: off by one if there is a CLOSE companion or if both orbitCount + maxCompanion are zero
    } else {
      return new Orbit[_orbitCount];
    }    
  }
  
  Boolean orbitIsFar(int _orbitNum){
    return _orbitNum >= 14;  // Scouts p.46 - does not assign orbit numbers to "Far" (just AU values), but this is equivalent and easier to handle in rest of methods
  }
  
  // from tables on Scouts p.46
  int setCompanionOrbits(){
    int maxCompanion = 0;
    for (int i = 0; i < companions.size(); i++){
      int modifier = 4 * (i);
      if (!primary){ modifier -= 4; }
      println("Assessing companion star: " + companions.get(i) + " modifier: +" + modifier);
      int dieThrow = twoDice() + modifier;
      int result = 0;
      if (dieThrow < 4  ){ result = 0; }
      if (dieThrow == 4 ){ result = 1; }
      if (dieThrow == 5 ){ result = 2; }
      if (dieThrow == 6 ){ result = 3; }
      if (dieThrow == 7 ){ result = 4 + oneDie(); }
      if (dieThrow == 8 ){ result = 5 + oneDie(); }
      if (dieThrow == 9 ){ result = 6 + oneDie(); }
      if (dieThrow == 10){ result = 7 + oneDie(); }
      if (dieThrow == 11){ result = 8 + oneDie(); }
      if (dieThrow >= 12){ 
        int distance = 1000 * oneDie();                           // distance in AU, converted to orbit number below
        if (distance == 1000                    ){ result = 14; }
        if (distance == 2000                    ){ result = 15; }
        if (distance == 3000 || distance == 4000){ result = 16; }
        if (distance >= 5000                    ){ result = 17; } 
      }
      if (result > maxCompanion){ maxCompanion = result; }
      
      if (result == 0 || orbitInsideStar(result)){
        println("Companion in CLOSE orbit");        
        closeCompanion = companions.get(i);
        companions.remove(i);
        closeCompanion.orbitNumber = result;
      } else {
        println("Companion in orbit: " + result);
        companions.get(i).orbitNumber = result;
      }
      // TO_DO: need to handle two companions landing in same orbit
    }
    return maxCompanion;   // TO_DO: off by one in the CLOSE Companion case
  }
  
  char generateType(){
    int dieThrow = twoDice();
    if (primary){
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
  
  int generateSize(){
    int dieThrow = twoDice();
    if (primary){
      sizeRoll = dieThrow;
      if (dieThrow == 2                ){ return 2;  }
      if (dieThrow == 3                ){ return 3; }
      if (dieThrow == 4                ){ 
        if ((type == 'K' && decimal > 4) || type == 'M'){
          return 5;
        } else {
          return 4;
        }
      }
      if (dieThrow > 4 && dieThrow < 11){ return 5;   }
      if (dieThrow == 11               ){
        if (type == 'B' || type == 'A' || (type == 'F' && decimal < 5)){
          return 5;
        } else {
          return 6;
        }
      }
      if (dieThrow == 12               ){ return 7;   }
      return 9;
    } else {
      sizeRoll = 0;
      dieThrow += ((System_ScoutsEx)parent).primary.sizeRoll;
      if (dieThrow == 2                 ){ return 2;  }
      if (dieThrow == 3                 ){ return 3; }
      if (dieThrow == 4                 ){ 
        if ((type == 'K' && decimal > 4) || type == 'M'){
          return 5;
        } else {
          return 4;
        }  
      }
      if (dieThrow == 5 || dieThrow == 6){ return 7;   }
      if (dieThrow == 7 || dieThrow == 8){ return 5;   }
      if (dieThrow == 9                 ){ 
        if (type == 'B' || type == 'A' || (type == 'F' && decimal < 5)){
          return 5;
        } else {
          return 6;
        }          
      }
      if (dieThrow > 9                  ){ return 7;   }
      return 9;
    }
  }
  
  // parallel switch statements in these two methods
  // subclassing (even just for 'size') starts to seem appealing
  // go with rule of three for now
  String sizeToString(){
    switch(size) {
      // does not handle supergiants (Ia & Ib) but this system
      // can't generate them in any case - deal with later if we need to
      case 2:
        return "II";  // bright giants
      case 3:
        return "III"; // normal giants
      case 4:
        return "IV";  // subgiants
      case 5:
        return "V";   // main sequence / dwarfs
      case 6:
        return "VI";  // subdwarfs
      case 7:
        return "D";   // white dwarfs
      default:
        return "X";
    }
  }
  
  int sizeFromString(String _s){
    switch(_s) {
      case "II":
        return 2;
      case "III":
        return 3;
      case "IV":
        return 4;
      case "V":
        return 5;
      case "VI":
        return 6;
      case "D":
        return 7;
      default:
        return 9;
    }
  }
  
  int getCompanionCount(){
    println("Determining companion count for " + this);
    int dieThrow = twoDice();
    if (dieThrow < 8){ return 0; }
    if (dieThrow > 7 && dieThrow < 12){ return 1; }
    if (dieThrow == 12){ 
      if (primary){ 
        return 2; 
      } else {
        return 1;
      }
    }
    return 0;
  }

  int calculateMaxOrbits(){
    int modifier = 0;
    if (size == 2   ){ modifier += 8; }  // rules include Ia/Ib supergiants here, but no means to generate them - omitting
    if (size == 3   ){ modifier += 4; }
    if (type == 'M' ){ modifier -= 4; }
    if (type == 'K' ){ modifier -= 2; }

    int result = twoDice() + modifier; 
    if (result < 1){ 
      return 0; 
    } else {
      return result;
    }
  }  
  
  String toString(){
    if (size == 7){
      return sizeToString() + str(type);
    } else {
      return str(type) + decimal + sizeToString();
    }
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    
    json.setString("Class", this.toString());

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
      
    if (orbits != null && orbits.length > 0){   // TO_DO: temporary while we are wiring up companion orbits - currently array only created for primary & far companions
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

    if (!primary){
      json.setInt("Orbit", orbitNumber);
    }
    
    return json;
  }
}