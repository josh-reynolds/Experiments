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
  
  void newUWPFor(Habitable _h){
    _h.setUWP(new UWP_ScoutsEx((Orbit)_h));
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