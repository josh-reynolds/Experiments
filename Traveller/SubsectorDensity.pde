abstract class Density {
  int current;
  float[] values;
  String[] labels;  
  
  void next(){
    current++;
    current %= values.length;    
  }
  
  String getLabel(){
    return labels[current]; 
  }
  
  float getValue(){
    return values[current];
  }
}

// data from Scouts p. 25
// MegaTraveller uses the same values (Referee's Manual pp. 24 + 26)
// Traveller: New Era uses the same values (TNE p. 186 + 192)
class SubsectorDensity extends Density {  
  SubsectorDensity(){
    values  = new  float[]{ 0.5,        0.66,    0.04,   0.16,     0.33        };
    labels  = new String[]{ "Standard", "Dense", "Rift", "Sparse", "Scattered" };
    current = 0;   // "Standard" i.e. 50% chance
  }
}

// Traveller 5 extends the range of values and modifies others (T5 p. 421)
class SubsectorDensity_T5 extends Density {
  SubsectorDensity_T5(){
    values  = new  float[]{ 0.5,        0.66,    0.83,      0.91,   0.01,             0.03,   0.17,     0.33        };
    labels  = new String[]{ "Standard", "Dense", "Cluster", "Core", "Extra-Galactic", "Rift", "Sparse", "Scattered" };
    current = 0;   // "Standard" i.e. 50% chance
  }
}