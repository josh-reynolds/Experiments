// now that we've shifted to polymorphic structure, consider whether this should be an abstract base 
// class and a collection of interfaces - might handle the "supportsX" capabilities better
//
// should also consider some custom exception classes for the 'unsupported methods' in the
// hierarchy - though if the interface approach makes these unnecessary that's better
abstract class Ruleset {
  String name;
  
  Ruleset fromJSON(String _rules){
    switch(_rules){
      case "CT77":
        return new Ruleset_CT77();
      case "CT81":
        return new Ruleset_CT81();
      case "Scouts (Extended)":
        return new Ruleset_ScoutsEx();
      case "MegaTraveller (Extended)":
        return new Ruleset_MT();
      case "Traveller: The New Era (Extended)":
        return new Ruleset_TNE();
      default:
        return new Ruleset_CT77();
    }
  }
  
  abstract Ruleset next();   
  
  abstract Boolean supportsTravelZones();
  abstract Boolean supportsStars();
  abstract Boolean supportsDensity();
  abstract Boolean supportsTraffic();
  
  abstract Subsector newSubsector();
  abstract Density newSubsectorDensity();
  abstract System newSystem(Coordinate _coord, Boolean _occupied);
  abstract System newSystem(JSONObject _json);
  abstract OrbitBuilder newOrbitBuilder();
  abstract UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech); // "UWP at system level" rulesets
  abstract UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech); // "UWP at orbit level" rulesets
  abstract UWPBuilder newUWPBuilder();
  abstract Star newStar(System _parent); // primary stars
  abstract Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent); // companion stars
  abstract TradeClass newTradeClass(UWP _uwp, System _system);
}

class Ruleset_CT77 extends Ruleset {
  Ruleset_CT77(){ name = "CT77"; }
  
  Ruleset next(){
    return new Ruleset_CT81();
  }
  
  Boolean supportsTravelZones(){ return false; }
  Boolean supportsStars()      { return false; }
  Boolean supportsDensity()    { return false; }
  Boolean supportsTraffic()    { return false; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){ 
    return new System(_coord, _occupied); 
  }
  
  Subsector newSubsector(){ 
    return new Subsector(); 
  }
  
  Density newSubsectorDensity(){
    return new SubsectorDensity();
  }
  
  System newSystem(JSONObject _json){ 
    return new System(_json); 
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){ 
    return new TradeClass(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    println("Orbits not supported");
    return new OrbitBuilder();               // keeping the compiler happy - throw an exception instead?
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_ScoutsEx();        // throw an exception?
  }
  
  // primary stars
  Star newStar(System _parent){
    println("Stars not supported");
    return new Star(_parent);               // keeping the compiler happy - throw an exception instead?
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    println("Stars not supported");
    return new Star(_barycenter, _orbit, _zone, _parent);               // keeping the compiler happy - throw an exception instead?
  }
}

class Ruleset_CT81 extends Ruleset {
  Ruleset_CT81(){ name = "CT81"; }
  
  Ruleset next(){
    return new Ruleset_ScoutsEx();
  }
  
  Boolean supportsTravelZones(){ return true; }
  Boolean supportsStars()      { return false; }
  Boolean supportsDensity()    { return false; }
  Boolean supportsTraffic()    { return false; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){ 
    return new System_CT81(_coord, _occupied); 
  }
  
  Subsector newSubsector(){ 
    return new Subsector(); 
  }

  Density newSubsectorDensity(){
    return new SubsectorDensity();
  }
  
  System newSystem(JSONObject _json){ 
    return new System_CT81(_json); 
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder_CT81(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){ 
    return new TradeClass_CT81(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    println("Orbits not supported");
    return new OrbitBuilder();               // keeping the compiler happy - throw an exception instead?
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_ScoutsEx();        // throw an exception?
  }
  
  // primary stars
  Star newStar(System _parent){
    println("Stars not supported");
    return new Star(_parent);               // keeping the compiler happy - throw an exception instead?
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    println("Stars not supported");
    return new Star(_barycenter, _orbit, _zone, _parent);               // keeping the compiler happy - throw an exception instead?
  }
}

class Ruleset_ScoutsEx extends Ruleset {
  Ruleset_ScoutsEx(){ name = "Scouts (Extended)"; }
  
  Ruleset next(){
    return new Ruleset_MT();
  }
  
  Boolean supportsTravelZones(){ return true; }
  Boolean supportsStars()      { return true; }
  Boolean supportsDensity()    { return true; }
  Boolean supportsTraffic()    { return false; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){ 
    return new System_ScoutsEx(_coord, _occupied); 
  }
  
  Subsector newSubsector(){ 
    return new Subsector(); 
  }

  Density newSubsectorDensity(){
    return new SubsectorDensity();
  }
  
  System newSystem(JSONObject _json){ 
    return new System_ScoutsEx(_json); 
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder_ScoutsEx(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){ 
    return new TradeClass_ScoutsEx(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    return new OrbitBuilder();
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);  // throw an exception?
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_ScoutsEx(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }
  
  // primary stars
  Star newStar(System _parent){
    return new Star(_parent);
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    return new Star(_barycenter, _orbit, _zone, _parent);
  }
}

class Ruleset_MT extends Ruleset {
  Ruleset_MT(){ name = "MegaTraveller (Extended)"; }
  
  Ruleset next(){
    return new Ruleset_TNE();
  }
  
  Boolean supportsTravelZones(){ return true; }
  Boolean supportsStars()      { return true; }
  Boolean supportsDensity()    { return true; }
  Boolean supportsTraffic()    { return true; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){ 
    return new System_MT(_coord, _occupied); 
  }
  
  Subsector newSubsector(){ 
    return new Subsector_MT(); 
  }

  Density newSubsectorDensity(){
    return new SubsectorDensity();
  }  
  
  System newSystem(JSONObject _json){ 
    return new System_ScoutsEx(_json);       // TO_DO: need to implement JSON support for MT ruleset 
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder_MT(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){ 
    return new TradeClass_MT(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    return new OrbitBuilder_MT();
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);   // throw an exception?
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_MT(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }
  
  // primary stars
  Star newStar(System _parent){
    return new Star_MT(_parent);
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    return new Star_MT(_barycenter, _orbit, _zone, _parent);
  }
}

class Ruleset_TNE extends Ruleset {
  Ruleset_TNE(){ name = "Traveller: The New Era (Extended)"; }
  
  Ruleset next(){
    return new Ruleset_T4();
  }
  
  Boolean supportsTravelZones(){ return true; }
  Boolean supportsStars()      { return true; }
  Boolean supportsDensity()    { return true; }
  Boolean supportsTraffic()    { return true; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){
    return new System_MT(_coord, _occupied); 
  }
  
  Subsector newSubsector(){
    return new Subsector_MT(); 
  }

  Density newSubsectorDensity(){
    return new SubsectorDensity();
  }  
  
  System newSystem(JSONObject _json){ 
    return new System_ScoutsEx(_json);       // TO_DO: need to implement JSON support for MT ruleset 
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder_MT(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){
    return new TradeClass_TNE(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    return new OrbitBuilder_TNE();
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);   // throw an exception?
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_TNE(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }
  
  // primary stars
  Star newStar(System _parent){
    return new Star_TNE(_parent);
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    return new Star_TNE(_barycenter, _orbit, _zone, _parent);
  }
}

// Traveller 4 - looks most similar to CT81
class Ruleset_T4 extends Ruleset {
  Ruleset_T4(){ name = "Traveller 4"; }
  
  Ruleset next(){
    return new Ruleset_T5();
  }
  
  Boolean supportsTravelZones(){ return true; }
  Boolean supportsStars()      { return false; }
  Boolean supportsDensity()    { return false; }
  Boolean supportsTraffic()    { return false; }
  
  System newSystem(Coordinate _coord, Boolean _occupied){
    return new System_CT81(_coord, _occupied); 
  }
  
  Subsector newSubsector(){
    return new Subsector(); 
  }

  Density newSubsectorDensity(){
    return new SubsectorDensity();
  }  
  
  System newSystem(JSONObject _json){ 
    return new System_CT81(_json);  
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder_CT81(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){
    return new TradeClass_T4(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    return new OrbitBuilder();
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81 + T4)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);   // throw an exception?
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_MT(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }
  
  // primary stars
  Star newStar(System _parent){
    return new Star(_parent);
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    return new Star(_barycenter, _orbit, _zone, _parent);
  }
}

// Traveller 5 framework - need to build up classes, just copying from T4 to get started
// shifting to TNE as the basic framework as T5 includes full system/orbit generation
// change of plans: we're going to pull together a 'continuation' method, so this will start with a basic 'without orbits' System
class Ruleset_T5 extends Ruleset {
  Ruleset_T5(){ name = "Traveller 5"; }
  
  Ruleset next(){
    return new Ruleset_CT77();
  }
  
  Boolean supportsTravelZones(){ return true; }
  Boolean supportsStars()      { return false; }    // TO_DO: will re-enable once the continuation method is working
  Boolean supportsDensity()    { return true; }
  Boolean supportsTraffic()    { return false; }    // breaking with precedent, T5 does *not* have variable Starport presence (T5 p. 432)
  
  System newSystem(Coordinate _coord, Boolean _occupied){
    return new System_T5(_coord, _occupied); 
  }
  
  Subsector newSubsector(){
    return new Subsector(); 
  }

  Density newSubsectorDensity(){
    return new SubsectorDensity_T5();
  }  
  
  System newSystem(JSONObject _json){ 
    return new System_T5(_json);  
  }
  
  UWPBuilder newUWPBuilder(){ 
    return new UWPBuilder_T5(); 
  }
  
  TradeClass newTradeClass(UWP _uwp, System _system){
    return new TradeClass_T5(_uwp, _system); 
  }
  
  OrbitBuilder newOrbitBuilder(){
    return new OrbitBuilder_T5();
  }
  
  // should be used for "UWP at system level" rulesets (i.e. CT77 + CT81 + T4 + T5)
  UWP newUWP(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP(_starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);   // throw an exception?
  }

  // should be used for "UWP at orbit level" rulesets (i.e. Scouts Extended + MegaTraveller)
  UWP_ScoutsEx newUWP(Orbit _o, char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov, int _law, int _tech){
    return new UWP_TNE(_o, _starport, _size, _atmo, _hydro, _pop, _gov, _law, _tech);
  }
  
  // primary stars
  Star newStar(System _parent){
    return new Star_T5(_parent);
  }
  
  // companion stars
  Star newStar(Orbit _barycenter, int _orbit, String _zone, System _parent){
    return new Star_T5(_barycenter, _orbit, _zone, _parent);
  }
}