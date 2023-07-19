class Star extends Orbit {
  System parent;
  Boolean primary;
  
  char type;
  int typeRoll;
  int decimal;
  int size;
  int sizeRoll;
  
  Star closeCompanion;
  
  String[] orbitalZones;    // will hold data from data\OrbitalZones.csv

  int gasGiantCount = 0;    // TO_DO: only used by placeGasGiants/placePlanetoidBelts during construction
  
  // ctor for primary star only
  Star(System _parent){
    super(null, -1, (String)null);   // TO_DO: making the compiler happy, may need to rethink this - don't like the magic value for the primary
    if (debug == 2){ println("** Star PRIMARY ctor"); }
    primary = true;              //   need to work through values for barycenter on primary & companions, and whether that can make isPrimary obsolete
    parent = _parent;
    
    createStar();    
  }

  // primary ctor from JSON
  Star(System _parent, JSONObject _json){
    super(null, _json);
    primary = true;
    parent = _parent;
    
    spectralTypeFromString(_json.getString("Spectral Type"));
    orbitalZones = retrieveOrbitalZones();

    if (!_json.isNull("Close Companion Orbit")){
      closeCompanion = (Star)getOrbit(_json.getInt("Close Companion Orbit"));
    }

   // class                 - "Class" (inferred for Primary)                      - ok
   // parent                - arg                                                 - ok
   // primary               - inferred (how? for now separate ctors)              - ok
   // type / decimal / size - "Spectral Type"                                     - ok
   // typeRoll / sizeRoll   - only needed on construction, n/a                    - n/a
   // closeCompanion        - does this matter post-construction?                 - ok
   // orbitalZones          - recalculated (is this needed post-construction?)    - ok
   // gasGiantCount         - only needed on construction, n/a                    - n/a
   //  -- from Orbit superclass --
   // barycenter            - null for Primary                                    - ok
   // orbitNumber           - "Orbit", -1 for Primary                             - ok
   // orbitalZone           - null for Primary                                    - ok
   // captured              - n/a for Stars                                       - ok
   // offsetOrbitNumber     - n/a for Stars                                       - ok
   // orbits                - "Orbits"                                            -
   // roll                  - only needed on construction, n/a                    - n/a
  }  
  
  // ctor for companion stars
  Star(Orbit _barycenter, int _orbit, String _zone, System _parent){
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** Star COMPANION ctor"); }
    primary = false;              //   need to work through values for barycenter on primary & companions, and whether that can make isPrimary obsolete
    parent = _parent;

    createStar();
  } 
  
  // companion ctor from JSON
  Star(Orbit _barycenter, System _parent, JSONObject _json){
    super(_barycenter, _json);   // TO_DO: see note above in ctor
    primary = false;
    parent = _parent;

    spectralTypeFromString(_json.getString("Spectral Type"));
    orbitalZones = retrieveOrbitalZones();
  }

  Star(Boolean _primary, System _parent, String _s){
    super(null, -1, (String)null);   // TO_DO: see note above in ctor
    primary = _primary;
    parent = _parent;
    
    spectralTypeFromString(_s);
    
    orbitalZones = retrieveOrbitalZones();
  }  
  
  Boolean isStar(){ return true; }

  Boolean isPrimary(){ 
    if (primary != null){
      return primary;
    } else {
      return false;
    }
  }
  
  Boolean isCompanion(){
    return !isPrimary();
  }
  
  void createStar(){
    type = generateType();  
    decimal = floor(random(10));
    size = generateSize();
    if (size == 7){ decimal = 0; }
    
    orbitalZones = retrieveOrbitalZones();
  }
  
  // MegaTraveller uses the same odds for both Primary and Companion stars (MTRM p. 26)
  char generateType(){
    int dieThrow = roll.two();
    if (isPrimary()){
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
  
  // MegaTraveller uses the same odds for Primary, but changed the Companion table (MTRM p.26)
  // The table is now identical to Primary, so I wonder if this was a copy/paste typo?
  // TO_DO: In any case, will implement RAW
  int generateSize(){
    int dieThrow = roll.two();
    if (isPrimary()){
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

  void spectralTypeFromString(String _s){
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

  String getSpectralType(){
    if (size == 7){
      return sizeToString() + str(type);
    } else {
      return str(type) + decimal + sizeToString();
    }
  }

  // this data can back other queries, like the Forbidden orbit logic (same data source for both)
  // TO_DO: look for refactoring opportunities... also:
  // - table has inconsistencies w.r.t. rows, having to guess at some values for orbit 0 esp.
  // - the system by RAW cannot generate supergiants (Ia/Ib) or O/B stars, so could omit that data
  // - special case for M9 not handled yet - all other decimal values round to 0/5 for all spectral classes except M
  String[] retrieveOrbitalZones(){
    String[] output = new String[21];
    
    // data from Scouts pp. 29-31
    Table table = loadTable("OrbitalZones.csv", "header");  // probably want to load this as a global resource
    String classForLookup = "";
    if (size < 7){  // white dwarfs (size 7) have a different naming convention, don't need to worry about decimal value
      int roundedDecimal  = floor(decimal/5) * 5;
      classForLookup = str(type) + roundedDecimal + sizeToString();  // duplication from getSpectralType()
    } else {
      classForLookup = getSpectralType();
    }
          
    for (TableRow row : table.rows()){
      if (row.getString("Class").equals(classForLookup)){
        for (int i = 0; i < output.length; i++){
          output[i] = row.getString(str(i));
        }
      }
    }
    return output;
  }
  
  // NOTE: this is currently called from Star.designateMainworld(), so can't remove just yet
  // three cases:
  //  - DONE  orbit is inside star (have query method)
  //  - DONE  orbit is suppressed by nearby companion star
  //  -         TO_DO (Far companion case is unclear - in RAW, they don't have an orbit num so are not evaluated in this test)
  //  - DONE  orbit is too hot to allow planets
  void placeForbiddenOrbits(int _maxOrbit){
    println("Determining forbidden orbits for " + this);
    for (int i = 0; i <= _maxOrbit; i++){
      if (orbitIsForbidden(i) && orbitIsNullOrEmpty(i)){
        addOrbit(i, new Forbidden(this, i, orbitalZones[i]));
      }
    }
  }

  // NOTE: this is currently called from Star.designateMainworld(), so can't remove just yet
  void placePlanets(int _maxOrbit){
    println("Placing Planets for " + this);
    for (int i = 0; i < _maxOrbit; i++){
      if (orbitIsNull(i)){
        addOrbit(i, new Planet(this, i, orbitalZones[i]));
      }
    }
  }

  Habitable designateMainworld(){
    println("Finding mainworld");
    // Scouts p. 37: "The main world is the world in the system which has the greatest
    //  population. If more than one world has the same population, then select the world
    //  which is in the habitable zone, or failing that, which is closest to the central
    //  star. The main world need not be a planet; it can be a satellite or an asteroid
    //  belt, or a small world. It may not be a ring. The main world need not orbit the 
    //  central star in the system; it may be in orbit around the binary companion,
    //  or it may orbit a gas giant or other world."
    
    ArrayList<Habitable> candidates = this.getAll(Habitable.class);
    
    // in some cases we can have a System with no Habitable orbits - need to insert one
    // to prevent NullPointerException downstream, and to comply with Traveller assumptions -
    // all systems can be represented by a UWP, which in terms here means 'has a Habitable'
    // RAW doesn't address this possibility, though it is possible there
    // simplest patch seems to be inserting a new Planet at the end of the orbits list
    if (candidates.size() == 0){
      println("No Habitables currently in-system - adding a new Planet");
      
      int newOrbit = orbits.size();
      Boolean addingOrbit = true;
      while (addingOrbit){
        placeForbiddenOrbits(newOrbit);                   // need to test whether new orbit is valid
        if (getOrbit(newOrbit) == null){
          addingOrbit = false;
        }
        newOrbit++;  
      }
      
      placePlanets(newOrbit);
      candidates = this.getAll(Habitable.class);
    }

    if (debug == 2){ println("**** Habitables list length = " + candidates.size()); }
    if (debug == 2){ println("**** Orbits = " + orbits); }
    
    int maxPop = -1;
    Habitable winner = null;
    for (Habitable h : candidates){
      if (h.getUWP().pop > maxPop){
        maxPop = h.getUWP().pop;
        winner = h;
      }
      
      // TO_DO: lot of casting here, look for redesign to clean this up
      if (h.getUWP().pop == maxPop){
        if (winner != null){                                                           // runtime null pointer error, though in practice this should always be assigned by this point
          if (((Orbit)h).isHabitableZone() || ((Orbit)winner).isHabitableZone()){      // habitable zone wins
            if (((Orbit)h).isHabitableZone()){ 
              winner = h;
            }
          } else {                                                                     // else closest to primary
            int direction = ((Orbit)h).getOrbitNumber() - ((Orbit)winner).getOrbitNumber();      // current list ordered low to high
            if (direction < 0){                                                        // so this may be redundant, but helps if list changes
              winner = h; 
            }                                          
          }
        }
      }
    }
    

    if (winner != null){                                                               // potential runtime null pointer error here too to guard against
      winner.setMainworld(true);                                 
      winner.completeUWP();
      ((System_ScoutsEx)parent).mainworld = winner;      /// TO_DO: need to rethink return value for this method... this is a hack
    }

    // need a separate loop as this depends on the value of the mainworld flag    
    for (Habitable h : candidates){
      if (!h.isMainworld()){
        h.completeUWP();
      }
    }
    
    return winner;
  }

  ArrayList<Star> getCompanions(){
    ArrayList<Star> comps = new ArrayList<Star>();
    Iterator<Float> orbitNumbers = orbitList();
    
    while(orbitNumbers.hasNext()){
      float f = orbitNumbers.next();
      if (getOrbit(f).isStar() && getOrbit(f) != closeCompanion){
        comps.add((Star)getOrbit(f));
        //comps.addAll( ((Star)obts.get(i)).getCompanions() );  // Companions of companions - rare
                                                                // also, doesn't match current usage for companions list
                                                                // leave out for now, consider later
                                                                // this method only returns companions orbiting THIS star
      }
    }
    return comps;
  }

  Boolean orbitIsTooHot(int _num){
    return orbitalZones[_num].equals("X");
  }

  // TO_DO: this is a core part of the orbit assignment algorithm, needed because we were using an array
  //  with a TreeMap that's not necessary - and would be broken in fact because the 'empty' slots don't exist
  //  could intercept in this method with a 'keyExists' call as we refactor the whole thing away
  //  in fact we already have that method in Orbit.orbitIsTaken()
  // TO_DO: these methods can be supplanted by the new class queries baked into the hierarchy
  //  won't catch null pointers, but ideally we've rooted out all such cases
  //  and should squash any remaining bugs if not
  Boolean orbitIsNull(int _num){
    if (orbitIsTaken(_num)){ 
      if (getOrbit(_num) == null){
        return true; 
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Boolean orbitIsNullOrEmpty(int _num){
    if (orbitIsNull(_num)){ return true; }
    if (getOrbit(_num).isEmpty()){ return true; }
    return false;
  }

  // Scouts includes data for Supergiants (Ia/Ib) but no means to generate randomly - leaving out
  // Tables are on pp. 29-31, implementing RAW
  // TO_DO: tables handle orbit 0 inconsistently, so this func is incomplete - need to derive additional data
  Boolean orbitInsideStar(int _num){
    return orbitalZones[_num].equals("Z");
  }

  Boolean orbitIsForbidden(int _num){
    return (orbitInsideStar(_num) || orbitMaskedByCompanion(_num) || orbitIsTooHot(_num));
  }

  // TO_DO: reconcile with similar queries in Orbit 
  Boolean orbitIsInnerZone(int _num){
    return orbitalZones[_num].equals("I");
  }

  Boolean orbitIsFar(int _num){
    return _num >= 14;  // Scouts p.46 - does not assign orbit numbers to "Far" (just AU values), but this is equivalent and easier to handle in rest of methods
  }

  Boolean orbitMaskedByCompanion(int _num){
    ArrayList<Star> comps = getCompanions();
    if (comps.size() == 0){
      return false;
    } else {
      for (int i = 0; i < comps.size(); i++){
        int compOrbit = comps.get(i).getOrbitNumber();
        if (debug >= 1){ print(" Evaluating companion mask for " + comps.get(i) + " in orbit " + compOrbit + " against " + _num); }
        
        // some ambiguity here from RAW (Scouts p.23)
        // rule states: Orbits closer to the primary than the companion's orbit must be numbered no more than half of the companion's orbit number (round fractions down)
        //              Orbits farther away than the companion must be numbered at least two greater than the companion's orbit number
        // examples state: in a system with a companion in orbit 2, orbit 0 is available and orbits 4 and higher are available             (why not orbit 1? half of 2)
        //                 in a system with a companion at orbit 5, orbits 0, 1 and 2 are available, and orbits 7 and higher are available (contrariwise, how is 2 OK? half of 5 rounded down is 2)
        // simplest is to assume first example is a typo, and orbit 1 should be available - then this is consistent - implementing this approach
        
        if (_num < compOrbit && _num > compOrbit/2 ){ if (debug >= 1){ println(" TRUE!");} return true; }
        if (_num == compOrbit                      ){ if (debug >= 1){ println(" TRUE!");} return true; } 
        if (_num > compOrbit && _num <= compOrbit+1){ if (debug >= 1){ println(" TRUE!");} return true; }
      }
      if (debug >= 1){ println(" FALSE");} return false;
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

  String toString(){ 
    String result = super.toString();
    result += " " + getSpectralType();
    return result;
  }

  JSONObject asJSON(){
    JSONObject json = super.asJSON();
    json.setString("Spectral Type", getSpectralType());

    if (closeCompanion != null){
      json.setInt("Close Companion Orbit", closeCompanion.orbitNumber);
    }
    
    return json;
  }
}