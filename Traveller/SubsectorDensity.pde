class SubsectorDensity {
  float value;
  int current;
  
  // data from Scouts p. 25
  // MegaTraveller uses the same values (Referee's Manual pp. 24 + 26)
  // Traveller: New Era uses the same values (TNE p. 186 + 192)
  float[] values  = { 0.04,   0.16,     0.33,        0.5,        0.66    };
  String[] labels = { "Rift", "Sparse", "Scattered", "Standard", "Dense" }; 
  
  SubsectorDensity(){
    current = 3;   // "Standard" i.e. 50% chance
    value = values[current];
  }
  
  void next(){
    current++;
    current %= values.length;
    value = values[current];
    
    println("@@@ super.next() : " + current + " " + value);
    printArray(values);
    printArray(labels);
    
  }
  
  String getLabel(){
    return labels[current];
  }
  
  float getValue(){
    return values[current];
  }
}

// Traveller 5 extends the range of values and modifies others (T5 p. 421)
class SubsectorDensity_T5 extends SubsectorDensity {
  float[] values  = { 0.01,             0.03,   0.17,     0.33,        0.5,        0.66,    0.83,      0.91  };
  String[] labels = { "Extra-Galactic", "Rift", "Sparse", "Scattered", "Standard", "Dense", "Cluster", "Core"};
  
  SubsectorDensity_T5(){
    println("@@@ SubsectorDensity_T5 ctor()");
    printArray(values);
    printArray(labels);
    current = 4;   // "Standard" i.e. 50% chance
    value = values[current];
  }
  
  //void next(){
  //  current++;
  //  current %= values.length;
  //  value = values[current];
    
  //  println("@@@ sub.next() : " + current + " " + value);
  //  printArray(values);
  //  printArray(labels);
    
  //}
}