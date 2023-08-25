// basic UWP Builder implements the CT77 rules from Book 3
class UWPBuilder {
  Dice roll;

  UWPBuilder(){
    roll = new Dice();
  }
  
  void newUWPFor(System _s){
    char starport = generateStarport();
    int size      = generateSize(); 
    int atmo      = generateAtmo(size);
    int hydro     = generateHydro(size, atmo);
    int pop       = generatePop();
    int gov       = generateGov(pop);
    int law       = generateLaw(gov);
    int tech      = generateTech(starport, size, atmo, hydro, pop, gov); 

    _s.uwp = new UWP(starport, size, atmo, hydro, pop, gov, law, tech);
  }
  
  // slightly unusual - instead of polymorphism, we have parallel sets of 
  // methods. I expect this to change as the design matures but ought to work for now.
  void newUWPFor(Habitable _h){
    if (debug == 2){ println("** UWPBuilder.newUWPFor(" + _h.getClass() + ")"); }
    Orbit o = (Orbit)_h;
    _h.setUWP(new UWP_ScoutsEx(o));   // this line goes away once we translate the ctor into this method
    
    //isPlanet = planet.isPlanet();
    println("isPlanet? : " + (o.isPlanet()));

    //size  = generateSize();
    int size = generateSizeFor(o);
    
    //generateBaseUWPValues();    // TO_DO: need to implement Scouts & MT overrides
    int atmo = generateAtmo(size);
    int hydro = generateHydro(size, atmo);
    int pop = generatePop();
    
    // temporary values - will be populated once mainworld is established
    char starport = 'X';
    int gov       = 0;
    int law       = 0;
    int tech      = 0;
    
    println(str(starport) + str(size) + str(atmo) + str(hydro) + str(pop) + str(gov) + str(law) + "-" + str(tech)); 
  }
  
  char generateStarport(){
    int dieThrow = roll.two();
    
    switch(dieThrow){
      case 2:
      case 3:
      case 4:
        return 'A';
      case 5:
      case 6:
        return 'B';
      case 7:
      case 8:
        return 'C';
      case 9:
        return 'D';
      case 10:
      case 11:
        return 'E';
      case 12:
        return 'X';
      default:
        println("Invalid result in generateStarport()");
        return 'Z';
    }
  }
  
  int generateSize(){ return roll.two(-2); }
    
  int generateSizeFor(Orbit _o){
    if (debug == 2){ println("**** UWPBuilder.generateSizeFor(Orbit) for " + this.getClass()); }  
    if (_o.isPlanetoid()){ return 0; }

    // MegaTraveller follows the same modifiers (MTRM p. 28)
    int modifier = 0;
    if (_o.getOrbitNumber() == 0  ){ modifier -= 5; }
    if (_o.getOrbitNumber() == 1  ){ modifier -= 4; }
    if (_o.getOrbitNumber() == 2  ){ modifier -= 2; }
    if (_o.isOrbitingClassM()){ modifier -= 2; }
    int result = roll.two(modifier - 2);  
    
    if (result <= 0){ result = 0; }

    return result;
  }
  
  int generateAtmo(int _size){
    int result = roll.two(_size - 7);
    if (_size == 0 || result < 0){ result = 0; }
    return result;
  }
  
  int generateHydro(int _size, int _atmo){
    int result = roll.two(_size - 7);
    if (_atmo <= 1 || _atmo >= 10){ result -= 4; }
    if (_size <= 1 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }

  int generatePop(){ return roll.two(-2); }
  
  int generateGov(int _pop){
    int result = roll.two(_pop - 7);
    if (result < 0){ result = 0; }
    return result;
  }

  int generateLaw(int _gov){
    int result = roll.two(_gov - 7);
    if (result < 0){ result = 0; }
    return result;
  }
  
  int generateTech(char _starport, int _size, int _atmo, int _hydro, int _pop, int _gov){
    int modifier = 0;
    
    if (_starport == 'A'){ modifier += 6; }
    if (_starport == 'B'){ modifier += 4; }
    if (_starport == 'C'){ modifier += 2; }
    if (_starport == 'X'){ modifier -= 4; }
    
    if (_size <= 1){              modifier += 2; }
    if (_size > 1 && _size <= 4){ modifier += 1; }
    
    if (_atmo <= 3 || _atmo >= 10){ modifier += 1; }
    
    if (_hydro == 9){  modifier += 1; }
    if (_hydro == 10){ modifier += 2; }
    
    if (_pop >= 1 && _pop <= 5){ modifier += 1; }
    if (_pop == 9){              modifier += 2; }
    if (_pop == 10){             modifier += 4; }
    
    if (_gov == 0 || _gov == 5){ modifier += 1; }
    if (_gov == 13){             modifier -= 2; }
    
    return roll.one(modifier);
  }  
}

class UWPBuilder_CT81 extends UWPBuilder {
  UWPBuilder_CT81(){ super(); }
 
  // starport identical to CT77
  // size identical to CT77
  // atmo identical to CT77
  // hydro slightly different - see override below
  // pop identical to CT77
  // gov identical to CT77
  // law identical to CT77
  // tech identical to CT77
  
  // size 1 worlds are no longer forced to 0 hydro
  // discrepancy between text (p. 7) and summary table (p. 12):
  //  - table is identical to CT77 (other than change above)
  //  - text adds ATMO instead of SIZE; using that here
  int generateHydro(int _size, int _atmo){
    int result    = roll.two(_atmo - 7);
    if (_atmo <= 1 || _atmo >= 10){ result -= 4; }
    if (_size == 0 || result < 0){ result = 0; }
    if (result > 10) { result = 10; }
    return result;
  }
}