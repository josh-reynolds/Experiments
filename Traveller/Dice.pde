class Dice {
  int one(){
    return floor(random(0,6)) + 1;
  }
  
  int one(int _modifier){
    return one() + _modifier;
  }
  
  int two(){
    return one() + one();
  }
  
  int two(int _modifier){
    return two() + _modifier;
  }
  
  // introduced in Traveller 5 - ranges from -5 to +5 
  //  and is equivalent to 2d-7 (same distribution + range)
  int flux(){
    return one() - one();
  }
  
  int flux(int _modifier){
    return flux() + _modifier;
  }
}

class DiceMock extends Dice {
  int value;
  
  DiceMock(int _value){
    value = _value;
  }
  
  int one(){ return value; }
  int two(){ return value; }
}