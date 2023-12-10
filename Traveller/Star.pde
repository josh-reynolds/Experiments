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

    adjustSpecialCases();
    
    orbitalZones = retrieveOrbitalZones();
  }
  
  void adjustSpecialCases(){}  // no-op stub to allow override in subclass
  
  char generateType(){
    int dieThrow = roll.two();
    
    if (isPrimary()){
      typeRoll = dieThrow;
      return primaryStarType(dieThrow);
    } else {
      typeRoll = 0;
      dieThrow += parent.primary.typeRoll;
      return companionStarType(dieThrow);
    }
  }
  
  char primaryStarType(int _dieThrow){
    if (_dieThrow == 2                ){ return 'A'; }
    if (_dieThrow > 2 && _dieThrow < 8){ return 'M'; }
    if (_dieThrow == 8                ){ return 'K'; }
    if (_dieThrow == 9                ){ return 'G'; }
    if (_dieThrow > 9                 ){ return 'F'; }
    return 'X';    
  }
  
  char companionStarType(int _dieThrow){
    if (_dieThrow == 2                  ){ return 'A'; } // because minimum modifier from primary is +2, results of 2,3 are not possible
    if (_dieThrow == 3 || _dieThrow == 4){ return 'F'; }
    if (_dieThrow == 5 || _dieThrow == 6){ return 'G'; }
    if (_dieThrow == 7 || _dieThrow == 8){ return 'K'; }
    if (_dieThrow > 8                   ){ return 'M'; }
    return 'X';
  }
  
  int generateSize(){
    int dieThrow = roll.two();
    if (isPrimary()){
      sizeRoll = dieThrow;
      return primarySize(dieThrow);
    } else {
      sizeRoll = 0;
      dieThrow += parent.primary.sizeRoll;
      return companionSize(dieThrow);
    }
  }

  int primarySize(int _dieThrow){
    if (_dieThrow == 2                ){ return 2;  }
    if (_dieThrow == 3                ){ return 3; }
    if (_dieThrow == 4                ){ 
      if ((type == 'K' && decimal > 4) || type == 'M'){
        return 5;
      } else {
        return 4;
      }
    }
    if (_dieThrow > 4 && _dieThrow < 11){ return 5;   }
    if (_dieThrow == 11               ){
      if (type == 'B' || type == 'A' || (type == 'F' && decimal < 5)){
        return 5;
      } else {
        return 6;
      }
    }
    if (_dieThrow == 12               ){ return 7;   }
    return 9;
  }

  int companionSize(int _dieThrow){
    if (_dieThrow == 2                 ){ return 2;  }
    if (_dieThrow == 3                 ){ return 3; }
    if (_dieThrow == 4                 ){ 
      if ((type == 'K' && decimal > 4) || type == 'M'){
        return 5;
      } else {
        return 4;
      }  
    }
    if (_dieThrow == 5 || _dieThrow == 6){ return 7;   }
    if (_dieThrow == 7 || _dieThrow == 8){ return 5;   }
    if (_dieThrow == 9                  ){ 
      if (type == 'B' || type == 'A' || (type == 'F' && decimal < 5)){
        return 5;
      } else {
        return 6;
      }          
    }
    if (_dieThrow > 9                  ){ return 7;   }
    return 9;
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
  // The tables in MegaTraveller are identical, no need to update the data files for this ruleset (MTRM p. 27)
  // Same is true for Traveller: New Era (T:NE p. 193)
  // TO_DO: MT errata p. 22 calls out some changes to the tables:
  //   Ib omitted as noted above, no need to change
  //   BxIII/BxIV/BxV: "remove entries from all three tables for star types B0 and B5."
  //   "existing errata has removed Star Size VI... this table can be removed."
  // Since we're currently sharing a single data file with Scouts, need to consider how (and whether) to implement
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

  Boolean orbitIsHabitableZone(int _num){
    return orbitalZones[_num].equals("H");
  }

  int getHabitableZoneNumber(){    
    if (orbitalZones[0].equals("O")){ return 0; }
    
    for (int i = 0; i < orbitalZones.length; i++){
      if (orbitIsHabitableZone(i)){ return i; }
    }
    return 0;   // keeping compiler happy, should be handled by logic above already
    
    // does not properly handle stars that have no habitable zone... alternate approach to consider below
    // use special case result of -1 to indicate no HZ
    
    //int result = -1;
    //for (int i = 0; i < orbitalZones.length; i++){
    //  if (orbitalZones[i].equals("O")){ break; }
    //  result = i;
    //}
    //return result;
    
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
      //T5 adds possibility of supergiants, need to incorporate here
      case 1:
        return "I";   // supergiants (not differentiating between Ia + Ib yet - TO_DO)
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

// subclass for MegaTraveller rules - largely the same as Scouts (implemented in the parent Star class)
class Star_MT extends Star {
  Star_MT(System _parent){ super(_parent); }
  Star_MT(System _parent, JSONObject _json){ super(_parent, _json); }  
  Star_MT(Orbit _barycenter, int _orbit, String _zone, System _parent){ super(_barycenter, _orbit, _zone, _parent); } 
  Star_MT(Orbit _barycenter, System _parent, JSONObject _json){ super(_barycenter, _parent, _json); }
  Star_MT(Boolean _primary, System _parent, String _s){ super(_primary, _parent, _s); }  

  // For createStar(), mostly identical to Scouts but needed to add override method adjustSpecialCases()
  // Also, one confusing comment in errata (p. 22):
  //   "Star types M4V through M9V cannot have habitable worlds: subtract 6 from the decimal classification
  //    for primary stars."
  // Not clear what this is trying to accomplish? Are they forcing every system to have a habitable-capable
  //   primary star? Per the zones table, they could still have outer zone planets.
  // Not going to take this one up.  
  void adjustSpecialCases(){
    if ((type == 'A' || type == 'F' || type == 'G') &&
        (size == 2 || size == 3)){ size = 5; }    // errata p. 22:
                                                  //  "Star types A, F and G are extremely rare with star sizes II and III: change 
                                                  //   star size to V."
  }

  // MegaTraveller changes Primary type distribution slightly from Scouts
  char primaryStarType(int _dieThrow){
    if (_dieThrow == 2                   ){ return 'A'; }
    if (_dieThrow > 2 && _dieThrow < 8   ){ return 'M'; }
    if (_dieThrow == 8                   ){ return 'K'; }
    if (_dieThrow == 9 || _dieThrow == 10){ return 'G'; }    // change from RAW acccording to errata p. 22
    if (_dieThrow > 10                   ){ return 'F'; }
    return 'X';    
  }

  // MegaTraveller uses same companionStarType distribution as Scouts 

  // MegaTraveller RAW uses the same odds for Primary, but changed the Companion table (MTRM p.26)
  // However errata p. 22 lists changes to this method that bring it more inline with super
  int primarySize(int _dieThrow){
    if (_dieThrow == 2                ){ return 2;  }
    if (_dieThrow == 3                ){ return 3; }
    if (_dieThrow == 4                ){ 
      if ((type == 'K' && decimal > 4) || type == 'M'){
        return 5;
      } else {
        return 4;
      }
    }  
    if (_dieThrow > 4                 ){ return 5;   }  // change from RAW according to errata p. 22
    return 9;
  }

  int companionSize(int _dieThrow){
    if (_dieThrow == 2                ){ return 2;  } // because minimum modifier from primary is +2, results
    if (_dieThrow == 3                ){ return 3; }  // of 2,3 are not possible
    if (_dieThrow == 4                ){ 
      if ((type == 'K' && decimal > 4) || type == 'M'){
        return 5;
      } else {
        return 4;
      }
    }  
    if (_dieThrow > 4 && _dieThrow < 12){ return 5;   }  // change from RAW according to errata p. 22
    if (_dieThrow > 11                ){ 
      int primarySize = parent.primary.size;
      if (primarySize == 2 || primarySize == 3 || primarySize == 4){   // change from RAW according to errata p. 22
        return 7;
      } else {
        return 5;
      }
    }
    return 9;
  }

  // MegaTraveller expresses orbitMaskedByCompanion via a table (MTRM p.26) rather than the calculations
  // in Scouts, which removes some of the ambiguities in my comments above - the end result is identical
  // so the logic as originally coded is correct
}

class Star_TNE extends Star_MT{
  Star_TNE(System _parent){ super(_parent); }
  Star_TNE(System _parent, JSONObject _json){ super(_parent, _json); }  
  Star_TNE(Orbit _barycenter, int _orbit, String _zone, System _parent){ super(_barycenter, _orbit, _zone, _parent); } 
  Star_TNE(Orbit _barycenter, System _parent, JSONObject _json){ super(_barycenter, _parent, _json); }
  Star_TNE(Boolean _primary, System _parent, String _s){ super(_primary, _parent, _s); }    

  // New Era follows the same procedure for Primary Type
  // but the Companions type table has changed (T:NE p. 192)
  char companionStarType(int _dieThrow){
    if (_dieThrow == 4                   ){ return 'A'; }
    if (_dieThrow == 5 || _dieThrow == 6 ){ return 'F'; }
    if (_dieThrow == 7 || _dieThrow == 8 ){ return 'G'; }
    if (_dieThrow == 9 || _dieThrow == 10){ return 'K'; }
    if (_dieThrow > 10                   ){ return 'M'; }
    return 'X';
  }

  // New Era follows the same procedure for Primary Size
  //  (though note that the special case for class K stars is handled during decimal classification there,
  //   but using the MT approach should be equivalent and avoids needing to override this method)
  // The Companions size table changed in T:NE (T:NE p. 192)
  int companionSize(int _dieThrow){
    if (_dieThrow == 4                ){ return 2; }
    if (_dieThrow == 5                ){ return 3; }
    if (_dieThrow == 6                ){ 
      if ((type == 'K' && decimal > 4) || type == 'M'){  // T:NE RAW omits this special case for companions
        return 5;                                        // but it should still apply - cannot have M*IV or K5+IV stars
      } else {
        return 4;
      }
    }  
    if (_dieThrow > 6 && _dieThrow < 14){ return 5; }
    if (_dieThrow > 13                ){ 
      if (roll.one() < 4){
        return 5;
      } else {
        return 7;
      }
    }
    return 9;
  }
  
  // T:NE repeats the MegaTraveller table that maps to orbitMaskedByCompanion (T:NE p. 192)
}

class Star_T5 extends Star_TNE {
  Star_T5(System _parent){ super(_parent); }
  Star_T5(System _parent, JSONObject _json){ super(_parent, _json); }  
  Star_T5(Orbit _barycenter, int _orbit, String _zone, System _parent){ super(_barycenter, _orbit, _zone, _parent); } 
  Star_T5(Orbit _barycenter, System _parent, JSONObject _json){ super(_barycenter, _parent, _json); }
  Star_T5(Boolean _primary, System _parent, String _s){ super(_primary, _parent, _s); }    

  // T5 uses flux (d6-d6) instead of 2d6, but the curve is the same and a simple conversion (2d6-7 equivalent to d6-d6)
  //  it also adjusts the type distribution a bit (not sure I like this one, biased towards G stars instead of M)
  char primaryStarType(int _dieThrow){
    int flux = _dieThrow - 7;
    // table on p. 436 includes classes O, B and BD (Brown Dwarf), but not possible to roll that result for primaries - omitting
    if (flux <= -4                   ){ return 'A'; }
    if (flux >= -3 && flux <= -2     ){ return 'F'; }  
    if (flux >= -1 && flux <= 0      ){ return 'G'; }
    if (flux >= 1 && flux <= 2       ){ return 'K'; }
    if (flux >= 3                    ){ return 'M'; }
    return 'X';    
  }

  // T5 has separate size tables per spectral type and also uses a flux die throw (T5 p. 436)
  // TO_DO: T5 includes (rare) possibility of supergiant stars, think I omitted from orbit tables
  //   might throw an exception on calling retrieveOrbitalZones()
  //   T5 itself doesn't use this type of table, but we're hooking into the process outlined in Star.createStar()
  int primarySize(int _dieThrow){
    int flux = _dieThrow - 7;
    int size = 5;   // default to main sequence dwarfs, can leave out of tables below
    
    if (type == 'A'){
      if (flux == -5 || flux == -4){ size = 1; }  // includes both Ia and Ib supergiants
      if (flux == -3              ){ size = 2; }
      if (flux == -2              ){ size = 3; }
      if (flux == -1              ){ size = 4; }
      if (flux == 5               ){ size = 7; }  // per the table, can't generate A*VI stars
    }
    if (type == 'F' || type == 'G' || type == 'K'){
      if (flux == -5 ){ size = 2; }
      if (flux == -4 ){ size = 3; }
      if (flux == -3 ){ 
        if (type == 'K' && decimal > 4){    // size IV not possible for K5-K9 stars 
          size = 5; 
        } else {
          size = 4;
        }
      }
      if (flux == 4  ){ 
        if (type == 'F' && decimal < 5){
          size = 5;                       // size VI not possible for F0-F4 stars
        } else {
          size = 6;          
        } 
      }
      if (flux == 5  ){ size = 7; }
    }
    if (type == 'M'){
      if (flux <= -3 ){ size = 2; }
      if (flux == -2 ){ size = 3; } 
      if (flux == 4  ){ size = 6; } // size IV not possible for M0-M9 stars
      if (flux == 5  ){ size = 7; }
    }
    
    return size;   
  }
  
  // same discussion here as under primaryStarType() above
  //  reviewing/debugging if flux values are correctly propagated
  //  value is Primary Flux + (1d-1)
  char companionStarType(int _dieThrow){
    // dieThrow passed in has been modified by primary score already, which is a 2d6 range
    // we actually need primary roll as flux plus 1d-1
    // will see about pulling this distinction higher, but for now we can probably just
    // retrieve the primary value, convert to flux and add the 1d-1
    
    int primaryFlux = parent.primary.typeRoll - 7;
    int flux = primaryFlux + roll.one(-1);

    if (flux <= -4                   ){ return 'A'; }
    if (flux >= -3 && flux <= -2     ){ return 'F'; }  
    if (flux >= -1 && flux <= 0      ){ return 'G'; }
    if (flux >= 1 && flux <= 2       ){ return 'K'; }
    if (flux >= 3 && flux <= 5       ){ return 'M'; }
    if (flux >= 6                    ){ return 'D'; }  // TO_DO: introducing new star type (Brown Dwarf) need to plumb this through
    return 'X';
  }

  // same discussion continues here - need to plumb through T5 flux values better, but do this for now
  // also, much duplication with the corresponding primary method (primarySize) - refactor that too
  int companionSize(int _dieThrow){
    int primaryFlux = parent.primary.sizeRoll - 7;
    int flux = primaryFlux + roll.one(2);     // new range with companion modifiers will be -2 to 13    
    int size = 5;   // default to main sequence dwarfs, can leave out of tables below
    
    if (type == 'A'){
      if (flux == -3              ){ size = 2; }
      if (flux == -2              ){ size = 3; }
      if (flux == -1              ){ size = 4; }
      if (flux == 5               ){ size = 7; }  // per the table, can't generate A*VI stars
      // values higher than 5 are size V for type A stars, which is the default value 
    }
    if (type == 'F' || type == 'G' || type == 'K'){
      if (flux == -3 ){ 
        if (type == 'K' && decimal > 4){    // size IV not possible for K5-K9 stars 
          size = 5; 
        } else {
          size = 4;
        }
      }
      if (flux == 5  ){ size = 7; }
      if (flux == 4 || flux >= 6){
        if (type == 'F' && decimal < 5){
          size = 5;                       // size VI not possible for F0-F4 stars
        } else {
          size = 6;          
        }
      }
    }
    if (type == 'M'){
      if (flux == -3 ){ size = 2; }
      if (flux == -2 ){ size = 3; } 
      if (flux == 4  ){ size = 6; } // size IV not possible for M0-M9 stars
      if (flux == 5  ){ size = 7; }
      if (flux >= 6  ){ size = 6; }
    }
    
    return size;
  }

  // T5 takes a different approach to orbital zones that's incompatible with the previous data file
  //  - it only designates Habitable Zones, no Inner/Outer/Forbidden (though they could be inferred)
  //  - all stars, including white dwarfs, are given an H zone
  //  - it doesn't use interpolation at decimal 0 & 5 to list, instead has explicit data points
  // For compatibility with existing code, probably simplest to translate the T5 data into its own CSV
  //  file and import into the same orbitalZones array used above
  // I'll fill in with just H/I/O, no forbidden zones
  //
  // TO_DO: other than the csv file name, this method is identical to original - refactor!
  String[] retrieveOrbitalZones(){
    String[] output = new String[21];
    
    // data from T5 p. 45 (also on pp. 438-442 but the two are not identical - check errata)
    // the first source is easier to use, so I'm going with that
    Table table = loadTable("OrbitalZones_T5.csv", "header");  // probably want to load this as a global resource
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
}