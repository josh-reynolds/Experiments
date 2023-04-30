class Dice {
  int one(){
    return floor(random(0,6)) + 1;
  }
  
  int two(){
    return one() + one();
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