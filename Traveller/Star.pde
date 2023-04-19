class Star extends Orbit {
  System parent;
  
  char type;
  int typeRoll;

  int decimal;

  String size;  // Roman numerals - should we store as ints instead?
  int sizeRoll;
  
  Star[] companions;
  
  Star(Boolean _primary, System _parent){
    parent = _parent;
    type = getType(_primary);  
    decimal = floor(random(10));
    size = getSize(_primary);
    if (size.equals("D")){ decimal = 0; }
  }
  
  Star(System _parent, String _s){
    parent = _parent;
    type = _s.charAt(0);
    decimal = int(_s.substring(1,2));
    size = _s.substring(2);
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
  
  String toString(){
    return str(type) + decimal + size; 
  }
}