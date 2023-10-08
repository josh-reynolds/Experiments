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
  }
}