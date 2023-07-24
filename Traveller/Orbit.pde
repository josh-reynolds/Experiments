abstract class Orbit {
  Orbit barycenter;  // not _exactly_ the right word, but closest to meaning of "thing I orbit around"     
  int orbitNumber;
  String orbitalZone;
  int orbitDepth;
  // radius in AU & km? as a query method?
  
  Boolean captured;
  float offsetOrbitNumber;
  
  TreeMap<Float, Orbit> orbits;
  
  Dice roll;    // if we move all creational methods to a builder, this probably moves out
  
  Orbit(Orbit _barycenter, int _orbit, String _zone){
    if (_barycenter != null){
      if (debug == 2){ println("** Orbit ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    } else {
      if (debug == 2){ println("** Orbit PRIMARY ctor(null, " + _orbit + ", " + _zone + ")"); }
    }
    barycenter = _barycenter;
    setOrbitNumber(_orbit);
    orbitalZone = _zone;
        
    if (barycenter != null){           // null for the primary
      if (barycenter.isStar()){
        if (((Star)barycenter).isCompanion()){   // failing during JSON load due to ordering, hack addition
          String fromPrimary   = ((Star)barycenter.barycenter).orbitalZones[barycenter.orbitNumber];          
          String fromCompanion = ((Star)barycenter).orbitalZones[orbitNumber];
          orbitalZone = adjustOrbitalZone(fromPrimary, fromCompanion); 
        }
      }
      
      orbitDepth = barycenter.orbitDepth + 1;
    } else {
      orbitDepth = 0;
    }
    
    captured = false;
    orbits = new TreeMap();
    roll = new Dice();
  }

  Orbit(Orbit _barycenter, JSONObject _json){
    barycenter = _barycenter;

    if (!_json.isNull("Captured")){
      setOrbitNumber(_json.getFloat("Offset"));
    } else {
      setOrbitNumber(_json.getInt("Orbit"));
    }

    if (!_json.isNull("Zone")){
      orbitalZone = _json.getString("Zone");
    } else {
      orbitalZone = null;  // primary star
    }
    
    if (!_json.isNull("UWP")){
      // json.setString("UWP", ((Habitable)this).getUWP().toString());
      // can't downcast, not clear *which* subclass we are at this point
      // possibilities:
      //   move this responsibility down to subclass ctors - but will be duplication
      //   add a method to Habitable interface, and cast via that
      //    but doesn't seem to work: (Habitable)this.setUWP(_json.getString("UWP"));
      //   try out first option
      
      // json.setJSONArray("Facilities", facilityList);
      // Facilities
      // same argument here
    }

    orbits = new TreeMap();
    if (!_json.isNull("Orbits")){
      JSONArray orbitList = _json.getJSONArray("Orbits");
      for (int i = 0; i < orbitList.size(); i++){
        JSONObject j = orbitList.getJSONObject(i);
        float index = 0;
        
        // two considerations:
        //   - JSONArray uses integer indices, but we need actual float values for the TreeMap
        //   - we need to figure out the class of the orbit instance to call the right ctor

        if (j.isNull("Captured")){
          index = j.getInt("Orbit");  
        } else {
          index = j.getFloat("Offset");
        }
        
        switch(j.getString("Class")){  // TO_DO: don't care for this hardcoding... look for dynamic way to do this
          case "Star":            
            addOrbit(index, new Star(this, ((Star)this).parent, j)); // TO_DO: unify + streamline Star ctors
            break;
          case "Empty":
            addOrbit(index, new Empty(this, j));
            break;
          case "Forbidden":
            addOrbit(index, new Forbidden(this, j));
            break;
          case "GasGiant":   
            addOrbit(index, new GasGiant(this, j));
            break;
          case "Planet":
            addOrbit(index, new Planet(this, j));
            break;          
          case "Planetoid":
            addOrbit(index, new Planetoid(this, j));
            break;          
          case "Moon":
            addOrbit(index, new Moon(this, j));
            break;          
          case "Ring":
            addOrbit(index, new Ring(this, j));
            break;
          default:
            println("Invalid class in JSON file: " + j.getString("Class"));
        }
      }
    }    
  }

  String adjustOrbitalZone(String _fromPrimary, String _fromCompanion){
    int primaryScore = scoreZone(_fromPrimary);
    int companionScore = scoreZone(_fromCompanion);
    if (primaryScore < companionScore){
      return _fromPrimary;
    } else {
      return _fromCompanion;
    }
  }
  
  int scoreZone(String _zone){
    switch(_zone){
      case "Z":
        return 0;
      case "X":
        return 1;
      case "I":
        return 2;
      case "H":
        return 3;
      case "O":
        return 4;
      default:
        return 5;
    }
  }


  int getOrbitNumber(){ return orbitNumber; }

  void setOrbitNumber(int _value){ 
    orbitNumber = _value;
    offsetOrbitNumber = _value;
    captured = false;
  }
  
  void setOrbitNumber(float _value){
    orbitNumber = round(_value);
    offsetOrbitNumber = _value;
    captured = true;
  }

  Orbit getOrbit(int _orbitNum){
    return getOrbit((float)_orbitNum);
  }
  
  Orbit getOrbit(float _orbitNum){
    return orbits.get(_orbitNum);
  }

  void addOrbit(int _orbitNum, Orbit _o){
    addOrbit((float)_orbitNum, _o);
  }

  void addOrbit(float _orbitNum, Orbit _o){
    orbits.put(_orbitNum, _o);
  }

  Iterator<Float> orbitList(){
    return orbits.keySet().iterator();
  }

  // pulled this method up to avoid duplication in GasGiant & Planet
  //  however, that means we need the moons list and generateSatelliteSize()
  //  in this class, even though most of the hierarchy does not use... may
  //  reverse this one but try it out for now
  // also, similarly named method in Star needs evaluation
  void createSatellites(int _satelliteCount){
    if (debug == 2){ println("**** Orbit.createSatellites(" + _satelliteCount + ") for " + this.getClass()); }
    if (_satelliteCount <= 0){
      if (debug == 2){ println("**** No satellites for " + this.getClass()); }
    } else {
      for (int i = 0; i < _satelliteCount; i++){
        int satelliteSize = generateSatelliteSize();     // just like with Planet/Planetoid, should we let UWP sort it out?
        if (satelliteSize == 0){
          if (debug == 2){  println("****** generating Ring for " + this.getClass()); }
          int orbitNum = generateSatelliteOrbit(i, true);
          addOrbit(orbitNum, new Ring(this, orbitNum, this.orbitalZone));
        } else {
          int orbitNum = generateSatelliteOrbit(i, false);
          if (debug == 2){ println("****** generating Moon for " + this.getClass()); }
          addOrbit(orbitNum, new Moon(this, orbitNum, this.orbitalZone, satelliteSize));
        }
      }
    }
  }
  
  // genericizing previous lookup methods (getAllHabitables, getAllGasGiants)
  <T> ArrayList<T> getAll(Class<T> _c){
    ArrayList<T> result = new ArrayList();
    
    if (_c.isInstance(this)){
      result.add((T)this);
    }
    
    Iterator<Float> orbitNumbers = orbitList();

    while (orbitNumbers.hasNext()){
      float f = orbitNumbers.next();
      Orbit child = getOrbit(f);
      result.addAll(child.getAll(_c));
    }
    
    return result;
  }
  
  // The original implementation for this method was closely based on the Scouts text
  // however, that method runs into infinite regression and stack overflow
  // when there are many moons (most likely case if there are more than three rings)
  // because retries can never find an available slot.
  //
  // This alternate approach has roughly the same spread, if not exactly the same
  // distribution biases. Rings will take orbits closer in; moons tend to cluster after
  // that, and extreme orbits only get assigned for Gas Giants (either via the 12+ roll
  // or because there are many moons and the options closer in are pruned away).
  int generateSatelliteOrbit(int _counter, Boolean _ring){
    // data from table on Scouts p. 28 (corresponding text on pp.36-7)  
    IntList availableOrbits = new IntList();
    availableOrbits.append( new int[]{1,1,1,2,2,3,3,4,5,6,7,8,9,10,11,12,13,15,20,25,30,35,40,45,50,55,60,65,75,100,125,150,175,200,225,250,275,300,325} );
    prune(availableOrbits);
    
    int low, high;
    
    // need to adapt as the list shrinks or we get out of bounds errors
    // this implementation is safe up to ~30 assignments
    // which amply covers the Scouts algorithm (LGG can have up to 12 satellites max)
    if (_ring){
      low = 0;
      high = min(availableOrbits.size()-1, low + 3);
    } else {
      // the table omits this detail, but the text says "apply a DM for each throw after first equal to the throw number - 1"
      // slightly ambiguous, but given the semicolon it seems to apply only to this first 'type' throw
      // it does mean that only the first moon of a Gas Giant can have an extreme orbit
      int dieThrow = roll.two(-_counter);
      if (dieThrow < 8){                          // Close orbits
        low = min(availableOrbits.size()-1, 6);
        high = min(availableOrbits.size()-1, low + 10);
      } else {
        if (dieThrow >= 12 && isGasGiant()){      // Extreme orbits
          low = availableOrbits.size()-10;
          high = availableOrbits.size()-1;
        } else {                                  // Far orbits
          low = min(availableOrbits.size()-1, 16);
          high = min(availableOrbits.size()-1, low + 10);
        }
      }
    }                                                 
  
    int index = floor(random(low, high));
    return availableOrbits.get(index);    
  }

  void prune(IntList _list){
    for (int i = _list.size()-1; i >= 0; i--){
      if (orbitIsTaken(_list.get(i))){
        _list.remove(i);
      }
    }
  }

  Boolean orbitIsTaken(int _orbit){
    return orbits.keySet().contains((float)_orbit);
  }

  int generateSatelliteSize(){ return 0; }  // keeping the compiler happy - see note above in createSatellites()

  Boolean isOrbitingClassM(){
    if (debug == 2){ println("**** Orbit.isOrbitingClassM() for " + this.getClass()); }
    if (barycenter.isStar()){
      return ((Star)barycenter).type == 'M';
    } else {
      return false;
    }
  }

  Boolean isInnerZone(){
    if (debug == 2){ println("**** Orbit.isInnerZone() for " + this.getClass()); }
    return orbitalZone.equals("I");
  }
  
  Boolean isHabitableZone(){
    if (debug == 2){ println("**** Orbit.isHabitableZone() for " + this.getClass()); }
    return orbitalZone.equals("H");
  }
  
  Boolean isOuterZone(){
    if (debug == 2){ println("**** Orbit.isOuterZone() for " + this.getClass()); }
    return orbitalZone.equals("O");
  }

  // TO_DO: we could greatly simplify this by adding another code to the data tables...
  //  but then we would have to OR the symbols together for outer zone queries, think about it
  Boolean isAtLeastTwoBeyondHabitable(){
    if (debug == 2){ println("**** Orbit.isAtLeastTwoBeyondHabitable() for " + this.getClass()); }
    if (isInnerZone() || isHabitableZone()){ return false; }
    if (barycenter.isPlanet()){ return ((Planet)barycenter).isAtLeastTwoBeyondHabitable(); }
    if (barycenter.isGasGiant()){ return ((GasGiant)barycenter).isAtLeastTwoBeyondHabitable(); }
    
    // find habitable zone (move this to method on Star? esp now that we have to downcast)
    int habitableOrbit = 0;
    Boolean foundHabitable = false;
    for (int i = 0; i < ((Star)barycenter).orbitalZones.length; i++){
      if (((Star)barycenter).orbitalZones[i].equals("H")){
        habitableOrbit = i;
        foundHabitable = true;
        break;
      }
    }

    // by RAW, undefined case: system has no habitable zone - we'll go with TRUE
    if (!foundHabitable){
      if (debug >= 1){ println("No habitable zone for " + barycenter); }
      return true;      
    } else {
      if (debug >= 1){ println("Habitable zone for " + barycenter + " in orbit " + habitableOrbit); }
      return (getOrbitNumber() - habitableOrbit >= 2);
    }
  }  
  
  Boolean isFar(){
    return barycenter.isStar() && orbitNumber >= 14;
  }
  
  Boolean insideStar(){
    if (debug == 2){ println("**** Orbit.insideStar() for " + this.getClass()); }
    return orbitalZone.equals("Z");
  }
  
  Boolean isContainer(){
    return orbits.size() > 0;
  }
  
  Boolean isStar(){ return false; }
  Boolean isEmpty(){ return false; }
  Boolean isForbidden(){ return false; }  
  Boolean isGasGiant(){ return false; }
  Boolean isPlanet(){ return false; }
  Boolean isPlanetoid(){ return false; }
  Boolean isMoon(){ return false; }
  Boolean isRing(){ return false; }
  Boolean isHabitable(){ return false; }

  String toString(){ 
    return this.getClass().getSimpleName();
  }
  
  String className(){
    return this.getClass().getSimpleName();
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    
    json.setInt("Orbit", orbitNumber);
    json.setString("Class", this.className());
    json.setString("Zone", orbitalZone);
    
    if (isHabitable()){      
      json.setString("UWP", ((Habitable)this).getUWP().toString());
      ArrayList<String> facilities = ((Habitable)this).getFacilities(); 
      if (facilities.size() > 0){
        JSONArray facilityList = new JSONArray();
        for (int i = 0; i < facilities.size(); i++){
          facilityList.setString(i, facilities.get(i));
        }
        json.setJSONArray("Facilities", facilityList);
      }
    }
    
    if (captured){
      json.setBoolean("Captured", captured);     // TO_DO: should push this down the hierarchy to Planet...
      json.setString("Offset", nfc(offsetOrbitNumber,1));  // using setFloat results in many decimal digits
    }                                                      //  this tweak is cosmetic only, and will need 
                                                           //  to convert back with float() on load
    
    if (isContainer()){
      JSONArray orbitsList = new JSONArray();
      int counter = 0;                         // need to manually manage due to captured planets
      
      Iterator<Float> orbitNumbers = orbitList();    
      while (orbitNumbers.hasNext()){
        float f = orbitNumbers.next();
        Orbit child = getOrbit(f);
        orbitsList.setJSONObject(counter, child.asJSON());
        counter++;
      }
      json.setJSONArray("Orbits", orbitsList);
    }
    return json;
  }
}

//class Star extends Orbit {} // separate file/tab for this one

class Empty extends Orbit {
  Empty(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
  }
  
  Empty(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
  }
  
  Boolean isEmpty(){ return true; }
}

class Forbidden extends Orbit {
  Forbidden(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone);
  }
  
  Forbidden(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
  }
  
  Boolean isForbidden(){ return true; }
}

class GasGiant extends Orbit {
  String size;       // potential to split this type code into subclasses, polymorphic logic below
    
  GasGiant(Orbit _barycenter, int _orbit, String _zone, StarBuilder _sb){ 
    super(_barycenter, _orbit, _zone);    
    if (debug == 2){ println("** GasGiant ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    if (roll.one() >= 4){ 
      size = "S";
    } else {
      size = "L";
    }

    int satelliteCount = _sb.generateSatelliteCountFor(this);
    createSatellites(satelliteCount);
  }  

  GasGiant(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
    size = _json.getString("Size");
  }
  
  int generateSatelliteSize(){
    int result = 0;
    if (size.equals("S")){
      result = roll.two(-6); 
    } else if (size.equals("L")){
      result = roll.two(-4);          
    }
    return result;
  }
  
  Boolean isGasGiant(){ return true; }
  
  String toString(){ 
    String result = super.toString();
    result += " (" + size + ")";
    return result;
  }
  
  JSONObject asJSON(){
    JSONObject json = super.asJSON();
    json.setString("Size", size);    
    return json;
  }
}

interface Habitable {   // distinct from "Habitable Zone" - this just means "has a UWP"
  abstract UWP getUWP();
  abstract UWP_ScoutsEx generateUWP();
  abstract void setMainworld(Boolean _isMainworld);
  abstract Boolean isMainworld();
  abstract void completeUWP();
  abstract void addFacility(String _facility);
  abstract ArrayList<String> getFacilities();
}

class Planet extends Orbit implements Habitable { 
  UWP_ScoutsEx uwp;
  Boolean mainworld;
  ArrayList<String> facilities;
  
  Planet(Orbit _barycenter, int _orbit, String _zone, StarBuilder _sb){ 
    super(_barycenter, _orbit, _zone);
    if (debug == 2){ println("** Planet ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ")"); }
    uwp = generateUWP();

    int satelliteCount = 0;
    if (!isMoon()){ 
      satelliteCount = _sb.generateSatelliteCountFor(this);  // need to handle Moon super call - StarBuilder is null there 
    }
    createSatellites(satelliteCount);

    mainworld = false;
    facilities = new ArrayList();
  }
  
  Planet(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
    uwp = new UWP_ScoutsEx(_json.getString("UWP"));
  }
  
  UWP_ScoutsEx getUWP(){ return uwp; }
    
  int generateSatelliteSize(){
    return this.uwp.size - roll.one();
  }
  
  UWP_ScoutsEx generateUWP(){
    if (debug == 2){ println("**** Planet.generateUWP() for " + this.getClass()); }
    return new UWP_ScoutsEx(this);    
  }

  void setMainworld(Boolean _isMainworld){ mainworld = _isMainworld; }
  Boolean isMainworld(){ return mainworld; }

  void completeUWP(){
    uwp.completeUWP(mainworld);
  }

  void addFacility(String _facility){
    facilities.add(_facility);
  }

  ArrayList<String> getFacilities(){
    return facilities;
  }

  Boolean isPlanet(){ return true; }
  Boolean isHabitable(){ return true; }
  
  String toString(){ 
    String result = "";
    if (isMainworld()){
      result += "MAINWORLD";
    } else {
      result += super.toString();
    }
    result += " : " + uwp;
    if (facilities.size() > 0){
      result += " " + getFacilities();
    }
    return result;
  }
}

class Planetoid extends Orbit implements Habitable {
  UWP_ScoutsEx uwp;
  Boolean mainworld;
  ArrayList<String> facilities;
  
  Planetoid(Orbit _barycenter, int _orbit, String _zone){ 
    super(_barycenter, _orbit, _zone); 
    uwp = generateUWP();
    mainworld = false;
    facilities = new ArrayList();
  }

  Planetoid(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
    uwp = new UWP_ScoutsEx(_json.getString("UWP"));
  }

  UWP getUWP(){ return uwp; }

  UWP_ScoutsEx generateUWP(){
    return new UWP_ScoutsEx(this);
  }

  void setMainworld(Boolean _isMainworld){ mainworld = _isMainworld; }
  Boolean isMainworld(){ return mainworld; }

  void completeUWP(){
    uwp.completeUWP(mainworld);
  }

  void addFacility(String _facility){
    facilities.add(_facility);
  }

  ArrayList<String> getFacilities(){
    return facilities;
  }

  Boolean isPlanetoid(){ return true; }
  Boolean isHabitable(){ return true; }
  
  String toString(){ 
    String result = "";
    if (isMainworld()){
      result += "MAINWORLD";
    } else {
      result += super.toString();
    }
    result += " : " + uwp;
    if (facilities.size() > 0){
      result += " " + getFacilities();
    }
    return result;
  }
}

// uncertain if following subclasses are needed
// Satellite is a Planet whose barycenter is not a Star (i.e. GasGiant or Planet)
// Ring is a Planetoid whose barycenter is not a Star (i.e. GasGiant or Planet)
// could just do this via queries

class Moon extends Planet {
  // need to work through inherited fields and hierarchy for these second-level children

  Moon(Orbit _barycenter, int _orbit, String _zone, int _size){
    super(_barycenter, _orbit, _zone, null);
    if (debug == 2){ println("** Moon ctor(" + _barycenter.getClass() + ", " + _orbit + ", " + _zone + ", " + _size + ")"); }
    
    uwp = generateUWP(_size); // super generates a UWP but doesn't have a size parameter
                              // and doing this via polymorphism seems like more code than
                              // this way
  }
  
  Moon(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
  }
  
  UWP_ScoutsEx generateUWP(int _size){
    return new UWP_ScoutsEx(this, _size);
  }
  
  Boolean isMoon(){ return true; }
}

class Ring extends Planetoid {
  Ring(Orbit _barycenter, int _orbit, String _zone){
    super(_barycenter, _orbit, _zone);
  }
  
  Ring(Orbit _barycenter, JSONObject _json){
    super(_barycenter, _json);
  }
  
  Boolean isRing(){ return true; }
}