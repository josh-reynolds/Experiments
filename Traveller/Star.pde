class Star extends Orbit {
  System parent;   // TO_DO: may want to rethink parent pointer for companions...
  Boolean primary;
  
  char type;
  int typeRoll;
  int decimal;
  int size;
  int sizeRoll;
  
  Star closeCompanion;
  
  Orbit[] orbits;
  String[] orbitalZones;    // will hold data from data\OrbitalZones.csv

  int gasGiantCount = 0;
  
  Star(Boolean _primary, System _parent){
    super(null, -1, (String)null);   // TO_DO: making the compiler happy, may need to rethink this - don't like the magic value for the primary
    primary = _primary;              //   need to work through values for barycenter on primary & companions, and whether that can make isPrimary obsolete
    parent = _parent;
    
    type = generateType();  
    decimal = floor(random(10));
    size = generateSize();
    if (size == 7){ decimal = 0; }
    
    orbitalZones = retrieveOrbitalZones();
  } 

  Star(Boolean _primary, System _parent, String _s){               // TO_DO: deprecate this ctor
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
      orbits = new Orbit[ob.size()];
      for (int i = 0; i < ob.size(); i++){                         // TO_DO: very fragile, will want to push out to subclasses and stop relying on string parsing
        if (ob.getString(i).equals("Null")){                       //          (some redundancy w/ companion list if we put JSONObjects here, though...) 
          orbits[i] = new Null(this, i, orbitalZones[i]);                                 // TO_DO: will go away once we populate all orbit variants 
        } else if (ob.getString(i).equals("Empty")){ 
          orbits[i] = new Empty(this, i, orbitalZones[i]); 
        } else {
          orbits[i] = new Star(false, parent, ob.getString(i));    // TO_DO: conflict/duplication with companion list - deprecate and rework this
        }
      }
    }
    
    if (!primary){
      orbitNumber = _json.getInt("Orbit");  // TO_DO: currently null for primary - all companions have a value
    }
  }
  
  Boolean isStar(){ return true; }
  
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
    String[] output = new String[18];
    
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
    int maxCompanionOrbit = 0;
    int compCount = 0;
    if (primary || orbitIsFar(orbitNumber)){
      compCount = generateCompanionCount();
    }
    println(compCount + " companions");
    
    ArrayList<Star> tempCompanions = new ArrayList<Star>();
    for (int i = 0; i < compCount; i++){
      tempCompanions.add(new Star(false, parent));
    }
    maxCompanionOrbit = generateCompanionOrbits(tempCompanions);

    int orbitCount = calculateMaxOrbits();
    if (!primary){ orbitCount = constrain(orbitCount, 0, floor(orbitNumber/2)); }
    orbits = createOrbits(orbitCount, maxCompanionOrbit);
    placeCompanions(orbitCount, maxCompanionOrbit, tempCompanions);
    
    // TO_DO: should we track orbital zones for companions? align w/ Orbit ctor? (same argument for orbit #)

    placeNullOrbits();    // TO_DO: probably temporary scaffolding to smooth addition of later elements
                          // unclear if still needed, was used for initial orbital zones approach, but that's changed
    
    placeEmptyOrbits(orbitCount, maxCompanionOrbit);
    placeForbiddenOrbits();
    placeCapturedPlanets();   // TO_DO: stub method, the decimal orbit values are tricky, need to think about it
    placeGasGiants();
    placePlanetoidBelts();
    placePlanets();
    
    ArrayList<Star> comps = getCompanions();
    for (Star c : comps){
      c.createSatellites();
    }
    if (closeCompanion != null){ closeCompanion.orbits = new Orbit[0]; } // otherwise we get a null reference later

    println("Companions for " + this);
    printArray(getCompanions());
  }    
    
  int generateCompanionCount(){
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

  // from tables on Scouts p.46
  int generateCompanionOrbits(ArrayList<Star> _comps){
    int maxCompanion = 0;
    for (int i = 0; i < _comps.size(); i++){
      int modifier = 4 * (i);
      if (!primary){ modifier -= 4; }
      println("Assessing companion star: " + _comps.get(i) + " modifier: +" + modifier);
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
        closeCompanion = _comps.get(i);
        _comps.remove(i);
        closeCompanion.orbitNumber = result;
      } else {
        println("Companion in orbit: " + result);
        _comps.get(i).orbitNumber = result;
      }
      // TO_DO: need to handle two companions landing in same orbit
    }
    return maxCompanion;   // TO_DO: off by one in the CLOSE Companion case - should this value also be a query?
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

  Orbit[] createOrbits(int _orbitCount, int _maxCompanion){
    if (_orbitCount <= _maxCompanion){
      return new Orbit[_maxCompanion+1];   // TO_DO: off by one if there is a CLOSE companion or if both orbitCount + maxCompanion are zero
    } else {
      return new Orbit[_orbitCount];
    }    
  }

  void placeCompanions(int _orbitCount, int _maxCompanion, ArrayList<Star> _comps){   // TO_DO: first two args only used in debug output, can be removed once this stabilizes
    if (_comps.size() == 0){
      println("Orbits: " + orbits.length);
    } else {
      println("Orbits: " + orbits.length + " EMPTY: " + (_maxCompanion - _orbitCount));
      for (int i = 0; i < _comps.size(); i++){
        println("Companion star number " + (i+1) + " of " + _comps.size() + " : Orbit = " + _comps.get(i).orbitNumber + " : Usable Orbit Count = " + _orbitCount);
        orbits[_comps.get(i).orbitNumber] = _comps.get(i);
      }
      if (closeCompanion != null){
        println("Close companion : Usable Orbit Count = " + _orbitCount);
      }
    }
  }

  void placeNullOrbits(){
    if (orbits.length > 0){
      for (int i = 0; i < orbits.length; i++){
        if (orbitIsNull(i)){
          orbits[i] = new Null(this, i, orbitalZones[i]);
        }
      }
    }
  }
  
  // this might read better as two separate methods...
  void placeEmptyOrbits(int _orbitCount, int _maxCompanion){
    println("Determining empty orbits for " + this);

    // Extra/empty orbits due to companions beyond generated orbit count
    if (_maxCompanion - _orbitCount > 0){
      int startCount = max(0, _orbitCount);
      for (int i = startCount; i < orbits.length; i++){  
        if (orbitIsNull(i)){
          orbits[i] = new Empty(this, i, orbitalZones[i]);
        }
      }
    }
    
    // Empty orbits per Scouts p.34 (table on p. 29)
    int modifier = 0;
    if (type == 'B' || type == 'A'){ modifier += 1; }
    if (oneDie() + modifier >= 5){
      int emptyCount = 0;
      switch(oneDie() + modifier){ 
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
        int choice = getRandomNullOrbit();
        if (choice == -1){ println("No null available"); break; } // don't much care for this 'magic value' - indicates no null orbits left
        println("Assigning " + choice + " to Empty");
        orbits[choice] = new Empty(this, choice, orbitalZones[choice]);
      }
    }
  }
  
  // three cases:
  //  - DONE  orbit is inside star (have query method)
  //  - DONE  orbit is suppressed by nearby companion star
  //  -         TO_DO (Far companion case is unclear - in RAW, they don't have an orbit num so are not evaluated in this test)
  //  - DONE  orbit is too hot to allow planets
  void placeForbiddenOrbits(){
    if (orbits.length > 0){
      for (int i = 0; i < orbits.length; i++){
        if ((orbitInsideStar(i) || orbitMaskedByCompanion(i) || orbitIsTooHot(i)) &&
            orbitIsNullOrEmpty(i)){
          orbits[i] = new Forbidden(this, i, orbitalZones[i]);
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
    if (twoDice() <= 9){
      switch(twoDice()){ 
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
      println(gasGiantCount + " Gas Giants in-system");   // need to consider at the System level, for Primary + all companions
      
      for (int i = 0; i < gasGiantCount; i++){
        availableOrbits.shuffle();
        int index = availableOrbits.remove(0);
        orbits[index] = new GasGiant(this, index, orbitalZones[index]);
      }
    } else {
      println("No Gas Giants in-system");
    }
  }
  
  // will be very similar to GasGiants, above - duplication OK for now, but look for refactorings
  void placePlanetoidBelts(){
    println("Placing Planetoid Belts for " + this);
    // uses # of Gas Giants as a modifier - rules don't specify, but I assume that means just for
    // the star which the potential planetoids orbit, not all companions
    int planetoidCount = 0;                      // not yet needed outside this method (MT and later include this count at System level, but IIRC Scouts does not)        
    if (twoDice() - gasGiantCount <= 6){
      switch(twoDice() - gasGiantCount){ 
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
      println(planetoidCount + " Planetoid Belts in-system");
    
      // RAW p. 35: "If possible, planetoid belts should be placed in the next orbit inward from gas giants."
      IntList orbitsInwardFromGiants = new IntList();   // might want to refactor this out, do it inline for now
      for (int i = 0; i < availableOrbits.size(); i++){
        int index = availableOrbits.get(i); 
        if (index == orbits.length-1){ continue; }
        if (orbits[index].isGasGiant()){
          orbitsInwardFromGiants.append(index);
          availableOrbits.remove(i);
        }
      }

      for (int i = 0; i < planetoidCount; i++){
        if (orbitsInwardFromGiants.size() > 0){
          orbitsInwardFromGiants.shuffle();
          int index = orbitsInwardFromGiants.remove(0);
          orbits[index] = new Planet(this, index, orbitalZones[index], true);
          continue;
        }
        if (availableOrbits.size() > 0){
          availableOrbits.shuffle();
          int index = availableOrbits.remove(0);
          orbits[index] = new Planet(this, index, orbitalZones[index], true);
        }
      }
    } else {
      println("No Planetoid Belts in-system");      
    }
  }

  void placePlanets(){
    for (int i = 0; i < orbits.length; i++){
      if (orbitIsNull(i)){
        orbits[i] = new Planet(this, i, orbitalZones[i], false);
      }
    }
  }

  // TO_DO: this needs to be more robust
  int getRandomNullOrbit(){
    int counter = 0;  // probably need to be more thoughtful if there are none available, but using counter to escape infinite loop just in case
    while(counter < 100){
      int choice = floor(random(2, orbits.length));  // see notes in placeEmptyOrbits() - 0 & 1 are 'protected'
      if (orbits.length <= 2){ break; }              // but this fails in the case of very small systems, so need to bail out
      if (orbitIsNull(choice)){
        return choice;
      }
      counter++;
    }
    return -1;  // and how would we handle this? will throw an exception when we use the value as an array index
  }

  IntList availableOrbitsForGiants(){
    // per Scouts p. 34: "The number (of Gas Giants) may not exceed the number of available and non-empty orbits in the habitable and outer zones"
    IntList result = new IntList();
    for (int i = 0; i < orbits.length; i++){
      if (orbitalZones[i].equals("Z") || orbitalZones[i].equals("X") || orbitalZones[i].equals("I")){ continue; }
      if (orbitIsNull(i)){                       // should we also allow them to drop into Empty orbits? by RAW, no
        println("Orbit " + i + " qualifies");
        result.append(i);
      }
    }
    println("Found " + result.size() + " available orbits for Gas Giants");
    return result;
    
    // TO_DO: one (awkward) special case:
    //   " (i)f the table calls for a gas giant and there is no orbit available for it, create an orbit in the outer zone for it"
  }

  // probably refactoring oppotunities w/ the similar Gas Giant method above - almost identical
  IntList availableOrbitsForPlanetoids(){
    IntList result = new IntList();
    for (int i = 0; i < orbits.length; i++){
      if (orbitIsNull(i)){                       // should we also allow them to drop into Empty orbits? by RAW, I think not
        println("Orbit " + i + " qualifies");    // though they never precisely define "available orbits"
        result.append(i);
      }
    }
    println("Found " + result.size() + " available orbits for Planetoids");    
    return result;
  }

  ArrayList<Star> getCompanions(){
    ArrayList<Star> comps = new ArrayList<Star>();
    
    for (int i = 0; i < orbits.length; i++){
      if (orbits[i].isStar()){
        comps.add((Star)orbits[i]);
        //comps.addAll( ((Star)orbits[i]).getCompanions() );  // Companions of companions - rare
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


  // TO_DO: these methods can be supplanted by the new class queries baked into the hierarchy
  //  won't catch null pointers, but ideally we've rooted out all such cases
  //  and should squash any remaining bugs if not
  Boolean orbitIsNull(int _num){
    return (orbits[_num] == null ||
            orbits[_num].isNull());
  }

  Boolean orbitIsNullOrEmpty(int _num){
    return (orbits[_num] == null ||
            orbits[_num].isEmpty() ||
            orbits[_num].isNull());
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
        print(" Evaluating companion mask for " + comps.get(i) + " in orbit " + compOrbit + " against " + _orbitNum);
        
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
      
    if (orbits != null && orbits.length > 0){   // null test was only needed for Close Companions - that has been fixed - assess removing this
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