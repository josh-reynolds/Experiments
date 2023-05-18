class Star extends Orbit {
  System parent;   // TO_DO: may want to rethink parent pointer for companions... (and I think this is always null anyway - BUG!)
  Boolean primary;
  
  char type;
  int typeRoll;
  int decimal;
  int size;
  int sizeRoll;
  
  Star closeCompanion;
  
  String[] orbitalZones;    // will hold data from data\OrbitalZones.csv

  int gasGiantCount = 0;
  
  Star(Boolean _primary, System _parent){
    super(null, -1, (String)null);   // TO_DO: making the compiler happy, may need to rethink this - don't like the magic value for the primary
    if (debug == 2){ println("** Star ctor(" + _primary);}// + _parent); }  // BUG:  _parent is null on the primary call because its ctor has not completed - reassess
    primary = _primary;              //   need to work through values for barycenter on primary & companions, and whether that can make isPrimary obsolete
    parent = _parent;
    
    type = generateType();  
    decimal = floor(random(10));
    size = generateSize();
    if (size == 7){ decimal = 0; }
    
    orbitalZones = retrieveOrbitalZones();
  } 

  Star(Boolean _primary, System _parent, String _s){
    super(null, -1, (String)null);   // TO_DO: see note above in ctor
    primary = _primary;
    parent = _parent;
    
    classFromString(_s);
    
    orbitalZones = retrieveOrbitalZones();
  }
  
  Star(Boolean _primary, System _parent, JSONObject _json){
    super(null, -1, (String)null);   // TO_DO: see note above in ctor
    primary = _primary;
    parent = _parent;
    
    classFromString(_json.getString("Class"));

    orbitalZones = retrieveOrbitalZones();

    if (!_json.isNull("Close Companion")){
      closeCompanion = new Star(false, parent, _json.getJSONObject("Close Companion")); 
    }

    if (!_json.isNull("Orbits")){
      JSONArray ob = _json.getJSONArray("Orbits");
      for (int i = 0; i < ob.size(); i++){                         // TO_DO: very fragile, will want to push out to subclasses and stop relying on string parsing
        if (ob.getString(i).equals("Null")){                       //          (some redundancy w/ companion list if we put JSONObjects here, though...) 
          orbits.put(i, new Null(this, i, orbitalZones[i]));         // TO_DO: may go away once we populate all orbit variants
        } else if (ob.getString(i).equals("Empty")){ 
          orbits.put(i, new Empty(this, i, orbitalZones[i]));
        } else {
          orbits.put(i, new Star(false, parent, ob.getString(i)));
        }
      }
    }
    
    if (!primary){
      orbitNumber = _json.getInt("Orbit");  // TO_DO: currently null for primary - all companions have a value
    }
  }
  
  Boolean isStar(){ return true; }
  
  char generateType(){
    int dieThrow = roll.two();
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
    int dieThrow = roll.two();
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
      classForLookup = str(type) + roundedDecimal + sizeToString();  // duplication from to_string()
    } else {
      classForLookup = this.toString();
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

  void createSatellites(){
    if (debug == 2){ println("Creating satellites for " + this); }
    int maxCompanionOrbit = 0;
    int compCount = 0;
    if (primary || orbitIsFar(orbitNumber)){
      compCount = generateCompanionCount();
    }    
    if (debug >= 1){ println(compCount + " companions"); }

    for (int i = 0; i < compCount; i++){
      Star companion = new Star(false, parent);    // BUG: are we propagating a null parent to all companions? is this value even useful, then?
      generateCompanionOrbits(companion, i);
      orbits.put(companion.orbitNumber, companion);
    }    
    maxCompanionOrbit = getMaxCompanionOrbit();

    // TO_DO: should we track orbital zones for companions? align w/ Orbit ctor? (same argument for orbit #)
    
    int orbitCount = calculateMaxOrbits();
    if (!primary){ orbitCount = constrain(orbitCount, 0, floor(orbitNumber/2)); }

    int max = max(orbitCount, maxCompanionOrbit + 1);
    placeNullOrbits(max);                                     // TO_DO: keeping for now, but this makes the TreeMap behave like an Array in some senses 
                                                              // the whole concept of null orbits may go away
    fillEmptyOrbits(orbitCount, maxCompanionOrbit);           // first half of Empty assignment - still needed?
    placeEmptyOrbits();                                       // second half of Empty assignment
    placeForbiddenOrbits();
    placeCapturedPlanets();                                   // TO_DO: stub method, can finally implement now with TreeMap
    placeGasGiants();
    placePlanetoidBelts();
    placePlanets();

    ArrayList<Star> comps = getCompanions();
    for (Star c : comps){
      c.createSatellites();
    }

    if (debug >= 1){ 
      println("Companions for " + this);
      printArray(getCompanions());
    }                                                                                                                  
  }    
    
  int generateCompanionCount(){
    println("Determining companion count for " + this);
    int dieThrow = roll.two();
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

  int getMaxCompanionOrbit(){
    ArrayList<Star> comps = getCompanions();
    int max = 0;
    for (Star s : comps){
      if (s.orbitNumber > max){ max = s.orbitNumber; } 
    }
    return max;
  }

  // from tables on Scouts p.46
  void generateCompanionOrbits(Star _companion, int _iteration){
    int modifier = 4 * (_iteration);
    if (!primary){ modifier -= 4; }
    if (debug >= 1){ println("Assessing companion star: " + _companion + " modifier: +" + modifier); }
    int dieThrow = roll.two(modifier);
    int result = 0;
    if (dieThrow < 4  ){ result = 0; }
    if (dieThrow == 4 ){ result = 1; }
    if (dieThrow == 5 ){ result = 2; }
    if (dieThrow == 6 ){ result = 3; }
    if (dieThrow == 7 ){ result = roll.one(4); }
    if (dieThrow == 8 ){ result = roll.one(5); }
    if (dieThrow == 9 ){ result = roll.one(6); }
    if (dieThrow == 10){ result = roll.one(7); }
    if (dieThrow == 11){ result = roll.one(8); }
    if (dieThrow >= 12){ 
      int distance = 1000 * roll.one();                           // distance in AU, converted to orbit number below
      if (distance == 1000                    ){ result = 14; }
      if (distance == 2000                    ){ result = 15; }
      if (distance == 3000 || distance == 4000){ result = 16; }
      if (distance >= 5000                    ){ result = 17; } 
    }
    
    if (result == 0 || orbitInsideStar(result)){
      if (debug >= 1){ println("Companion in CLOSE orbit"); }        
      closeCompanion = _companion;
      closeCompanion.orbitNumber = result;
    } else {
      if (debug >= 1){ println("Companion in orbit: " + result); }
      _companion.orbitNumber = result;
    }
    // TO_DO: need to handle two companions landing in same orbit
  }

  int calculateMaxOrbits(){
    int modifier = 0;
    if (size == 2   ){ modifier += 8; }  // rules include Ia/Ib supergiants here, but no means to generate them - omitting
    if (size == 3   ){ modifier += 4; }
    if (type == 'M' ){ modifier -= 4; }
    if (type == 'K' ){ modifier -= 2; }

    int result = roll.two(modifier); 
    if (result < 1){ 
      return 0; 
    } else {
      return result;
    }
  }  

  Orbit[] createOrbits(int _orbitCount, int _maxCompanion){  // TO_DO: only sizes the array - will go away once TreeMap is in place since that sizes dynamically
    if (_orbitCount <= _maxCompanion){
      return new Orbit[_maxCompanion+1];   // TO_DO: off by one if there is a CLOSE companion or if both orbitCount + maxCompanion are zero
    } else {
      return new Orbit[_orbitCount];
    }    
  }

  void placeNullOrbits(int _maxOrbit){    
    for (int i = 0; i < _maxOrbit; i++){
      if (!orbits.keySet().contains(i)){                                             // TO_DO: will be replaced with orbitIsTaken in the superclass
        orbits.put(i, new Null(this, i, orbitalZones[i]));
      }
    }
  }
  
  // splitting out first half of placeEmptyOrbits - method names need some improvement 
  // Extra/empty orbits due to companions beyond generated orbit count
  void fillEmptyOrbits(int _orbitCount, int _maxCompanion){
    if (_maxCompanion - _orbitCount > 0){
      int startCount = max(0, _orbitCount);
      for (int i = startCount; i < orbits.size(); i++){
        if (!orbits.keySet().contains(i) || orbits.get(i).isNull()){                    // TO_DO: will be replaced with orbitIsTaken in the superclass
          orbits.put(i, new Empty(this, i, orbitalZones[i]));
        }
      }
    }    
  }
  
  // see note under placeNull above - once we shift to TreeMap, this algorithm can be simplified or eliminated
  void placeEmptyOrbits(){
    println("Determining empty orbits for " + this);
    
    // Empty orbits per Scouts p.34 (table on p. 29)
    int modifier = 0;
    if (type == 'B' || type == 'A'){ modifier += 1; }
    if (roll.one(modifier) >= 5){
      int emptyCount = 0;
      switch(roll.one(modifier)){ 
        case 1:
        case 2:
          emptyCount = 1;
          break;
        case 3:
          emptyCount = 2;
          break;
        case 4:   // almost seems like a typo
        case 5:   // if a '4' roll returned 2, this would be a simple calculation
        case 6:   // notably, the captured planets column in same table is a simple oneDie()/2
        case 7:
          emptyCount = 3;
          break;
        default:
          emptyCount = 1;
          break;
      }
      
      for (int i = 0; i < emptyCount; i++){
        // By RAW, should roll twoDice() to find the empty orbit, but there are problems with that approach:
        //  - Will never choose orbits 0 or 1 (by design?)
        //  - Can generate more empty orbits than are available in the system
        //  - Bell curve bias towards orbits 6,7,8
        //  - Generates results outside existing orbits, needs lots of rerolls
        // I am going to implement a random picker that fixes the last two issues (flat curve, only existing orbits to choose from)
        //   and keep the protections for orbits 0 & 1 (maybe they wanted to ensure all systems have viable orbits?)
        int choice = getRandomUnassignedOrbit();
        if (choice == -1){ if (debug >= 1){ println("No null available"); } break; } // don't much care for this 'magic value' - indicates no null orbits left
        if (debug >= 1){ println("Assigning " + choice + " to Empty"); }
        orbits.put(choice, new Empty(this, choice, orbitalZones[choice]));
      }
    }
  }
  
  // three cases:
  //  - DONE  orbit is inside star (have query method)
  //  - DONE  orbit is suppressed by nearby companion star
  //  -         TO_DO (Far companion case is unclear - in RAW, they don't have an orbit num so are not evaluated in this test)
  //  - DONE  orbit is too hot to allow planets
  void placeForbiddenOrbits(){
    if (orbits.size() > 0){
      for (int i = 0; i < orbits.size(); i++){
        if ((orbitInsideStar(i) || orbitMaskedByCompanion(i) || orbitIsTooHot(i)) &&
            orbitIsNullOrEmpty(i)){
          orbits.put(i, new Forbidden(this, i, orbitalZones[i]));
        }
      }
    }
  }

  void placeCapturedPlanets(){
    println("Placing Captured Planets for " + this);
    // ambiguity here - some of the notes from Empty Orbits (above) also applies - but:
    //  - by RAW, these are placed in orbit 2-12 +/- deviation
    //  - same biases as noted under Empty: 0 & 1 protected, bell curve around 7, nothing beyond 12
    //  - no notes for what to do if orbit is occupied
    
    // offset value could get tricky
    //  only applies to captured planets, so want to keep integer orbit numbers
    //  instead add an 'offset' field to the Planet class only
    //  but how to represent and list in the orbit[] array?
    //  if, for example, we have a captured planet at orbit 8.5 and a 'regular' planet at 8 (as with Sol, Scouts p. 56)
    //  how is this listed?
  }

  void placeGasGiants(){
    println("Placing Gas Giants for " + this);
    if (roll.two() <= 9){
      switch(roll.two()){ 
        case 2:
        case 3:
          gasGiantCount = 1;
          break;        
        case 4:
        case 5:
          gasGiantCount = 2;
          break;        
        case 6:
        case 7:
          gasGiantCount = 3;
          break;        
        case 8:
        case 9:
        case 10:
          gasGiantCount = 4;        
          break;        
        case 11:
        case 12:
          gasGiantCount = 5;        
          break;
        default:
          gasGiantCount = 1;        
          break;
      }

      IntList availableOrbits = availableOrbitsForGiants();
      gasGiantCount = min(gasGiantCount, availableOrbits.size());
      if (debug >= 1){ println(gasGiantCount + " Gas Giants in-system"); }  // need to consider at the System level, for Primary + all companions
      
      for (int i = 0; i < gasGiantCount; i++){
        availableOrbits.shuffle();
        int index = availableOrbits.remove(0);
        orbits.put(index, new GasGiant(this, index, orbitalZones[index]));
      }
    } else {
      if (debug >= 1){ println("No Gas Giants in-system"); }
    }
  }
  
  // will be very similar to GasGiants, above - duplication OK for now, but look for refactorings
  void placePlanetoidBelts(){
    println("Placing Planetoid Belts for " + this);
    // uses # of Gas Giants as a modifier - rules don't specify, but I assume that means just for
    // the star which the potential planetoids orbit, not all companions
    int planetoidCount = 0;                      // not yet needed outside this method (MT and later include this count at System level, but IIRC Scouts does not)        
    if (roll.two(-gasGiantCount) <= 6){
      switch(roll.two(-gasGiantCount)){ 
        case -3:
        case -2:
        case -1:
        case 0:
          planetoidCount = 3;
          break;
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
          planetoidCount = 2;
          break;        
        default:
          planetoidCount = 1;        
          break;
      }
    
      IntList availableOrbits = availableOrbitsForPlanetoids();
      planetoidCount = min(planetoidCount, availableOrbits.size());
      if (debug >= 1){ println(planetoidCount + " Planetoid Belts in-system"); }
    
      // RAW p. 35: "If possible, planetoid belts should be placed in the next orbit inward from gas giants."
      IntList orbitsInwardFromGiants = new IntList();   // might want to refactor this out, do it inline for now
      for (int i = 0; i < availableOrbits.size(); i++){
        int index = availableOrbits.get(i); 
        if (index == orbits.size()-1){ continue; }
        if (orbits.get(index).isGasGiant()){
          orbitsInwardFromGiants.append(index);
          availableOrbits.remove(i);
        }
      }

      for (int i = 0; i < planetoidCount; i++){
        if (orbitsInwardFromGiants.size() > 0){
          orbitsInwardFromGiants.shuffle();
          int index = orbitsInwardFromGiants.remove(0);
          orbits.put(index, new Planetoid(this, index, orbitalZones[index]));
          continue;
        }
        if (availableOrbits.size() > 0){
          availableOrbits.shuffle();
          int index = availableOrbits.remove(0);
          orbits.put(index, new Planetoid(this, index, orbitalZones[index]));
        }
      }
    } else {
      if (debug >= 1){ println("No Planetoid Belts in-system"); }      
    }
  }

  void placePlanets(){
    println("Placing Planets for " + this);
    for (int i = 0; i < orbits.size(); i++){
      if (orbitIsNull(i)){
        orbits.put(i, new Planet(this, i, orbitalZones[i]));
      }
    }
  }

  // TO_DO: may want to set a flag on the chosen world for use in UWP completion
  Habitable designateMainworld(){
    println("Finding mainworld");
    // Scouts p. 37: "The main world is the world in the system which has the greatest
    //  population. If more than one world has the same population, then select the world
    //  which is in the habitable zone, or failing that, which is closest to the central
    //  star. The main world need not be a planet; it can be a satellite or an asteroid
    //  belt, or a small world. It may not be a ring. The main world need not orbit the 
    //  central star in the system; it may be in orbit around the binary companion,
    //  or it may orbit a gas giant or other world."
    
    ArrayList<Habitable> candidates = this.getAllHabitables();
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
            int direction = ((Orbit)h).orbitNumber - ((Orbit)winner).orbitNumber;      // current list ordered low to high
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
      println("MAINWORLD " + winner + " : System = " + parent + " : Mainworld = " + ((System_ScoutsEx)parent).mainworld);
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

  // replacement for getRandomNullOrbit() using TreeMap structure
  // flaws with this approach still exist and should be remedied later
  // TreeMap might give us some tools to simplify
  // TO_DO: this needs to be more robust
  int getRandomUnassignedOrbit(){
    int counter = 0;          // probably need to be more thoughtful if there are none available, but using counter to escape infinite loop just in case
    while(counter < 100){
      int choice = floor(random(2, orbits.size()));      // see notes in placeEmptyOrbits() - 0 & 1 are 'protected'
      if (orbits.size() <= 2){ break; }                  // but this fails in the case of very small systems, so need to bail out
      if (orbits.get(choice).isNull()){
        return choice;
      }
      counter++;
    }
    return -1;  // and how would we handle this? will throw an exception when we use the value as an array index      
  }

  IntList availableOrbitsForGiants(){
    // per Scouts p. 34: "The number (of Gas Giants) may not exceed the number of available and non-empty orbits in the habitable and outer zones"
    IntList result = new IntList();
    for (int i = 0; i < orbits.size(); i++){
      if (orbitalZones[i].equals("Z") || orbitalZones[i].equals("X") || orbitalZones[i].equals("I")){ continue; }
      if (orbitIsNull(i)){                       // should we also allow them to drop into Empty orbits? by RAW, no
        if (debug >= 1){ println("Orbit " + i + " qualifies"); }
        result.append(i);
      }
    }
    if (debug >= 1){ println("Found " + result.size() + " available orbits for Gas Giants"); }
    return result;
    
    // TO_DO: one (awkward) special case:
    //   " (i)f the table calls for a gas giant and there is no orbit available for it, create an orbit in the outer zone for it"
  }

  // probably refactoring oppotunities w/ the similar Gas Giant method above - almost identical
  IntList availableOrbitsForPlanetoids(){
    IntList result = new IntList();
    for (int i = 0; i < orbits.size(); i++){
      if (orbitIsNull(i)){                                         // should we also allow them to drop into Empty orbits? by RAW, I think not
        if (debug >= 1){ println("Orbit " + i + " qualifies"); }   // though they never precisely define "available orbits"
        result.append(i);
      }
    }
    if (debug >= 1){ println("Found " + result.size() + " available orbits for Planetoids"); }   
    return result;
  }

  ArrayList<Star> getCompanions(){
    ArrayList<Star> comps = new ArrayList<Star>();
    
    for (int i : orbits.keySet()){
      if (orbits.get(i).isStar()){
        comps.add((Star)orbits.get(i));
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
    if (orbits.keySet().contains(_num)){
      if (orbits.get(_num).isNull()){ 
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
    if (orbits.get(_num).isEmpty()){ return true; }
    return false;
  }

  // Scouts includes data for Supergiants (Ia/Ib) but no means to generate randomly - leaving out
  // Tables are on pp. 29-31, implementing RAW
  // TO_DO: tables handle orbit 0 inconsistently, so this func is incomplete - need to derive additional data
  // TO_DO: redundant with the data in orbitalZones[] - refactor
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

  Boolean orbitIsFar(int _orbitNum){
    return _orbitNum >= 14;  // Scouts p.46 - does not assign orbit numbers to "Far" (just AU values), but this is equivalent and easier to handle in rest of methods
  }

  Boolean orbitMaskedByCompanion(int _orbitNum){
    ArrayList<Star> comps = getCompanions();
    if (comps.size() == 0){
      return false;
    } else {
      for (int i = 0; i < comps.size(); i++){
        int compOrbit = comps.get(i).orbitNumber;
        if (debug >= 1){ print(" Evaluating companion mask for " + comps.get(i) + " in orbit " + compOrbit + " against " + _orbitNum); }
        
        // some ambiguity here from RAW (Scouts p.23)
        // rule states: Orbits closer to the primary than the companion's orbit must be numbered no more than half of the companion's orbit number (round fractions down)
        //              Orbits farther away than the companion must be numbered at least two greater than the companion's orbit number
        // examples state: in a system with a companion in orbit 2, orbit 0 is available and orbits 4 and higher are available             (why not orbit 1? half of 2)
        //                 in a system with a companion at orbit 5, orbits 0, 1 and 2 are available, and orbits 7 and higher are available (contrariwise, how is 2 OK? half of 5 rounded down is 2)
        // simplest is to assume first example is a typo, and orbit 1 should be available - then this is consistent - implementing this approach
        
        if (_orbitNum < compOrbit && _orbitNum > compOrbit/2 ){ if (debug >= 1){ println(" TRUE!");} return true; }
        if (_orbitNum == compOrbit                           ){ if (debug >= 1){ println(" TRUE!");} return true; } 
        if (_orbitNum > compOrbit && _orbitNum <= compOrbit+1){ if (debug >= 1){ println(" TRUE!");} return true; }
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
  
  // TO_DO: consider refactoring that pulled toString up to Orbit parent class
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
    
    ArrayList<Star> comps = getCompanions();
    if (comps.size() > 0){
      JSONArray companionList = new JSONArray();
      for (int i = 0; i < comps.size(); i++){
        companionList.setJSONObject(i, comps.get(i).asJSON());
      }
      json.setJSONArray("Companions", companionList);
    }
    
    if (orbits.size() > 0){
      JSONArray orbitsList = new JSONArray();
      for (int i = 0; i < orbits.size(); i++){
        if (orbits.get(i) != null){                            // TO_DO: eventually all orbits should be populated (only null during creation) and we can remove this clause
          orbitsList.setString(i, orbits.get(i).toString());   // TO_DO: for now only use Star JSON in companion lists above, redundant here
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