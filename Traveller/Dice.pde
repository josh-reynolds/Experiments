class Dice {
  int one(){
    return floor(random(0,6)) + 1;
  }
  
  int two(){
    return one() + one();
  } 
}