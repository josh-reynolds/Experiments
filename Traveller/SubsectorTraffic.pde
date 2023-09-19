// Introduced in MegaTraveller
class SubsectorTraffic {
  int current;
  
  // MTRM p. 24 (Step 3)
  String[] labels = { "Backwater", "Standard", "Mature", "Cluster" };
  char[][] values = {{'A','A','B','B','C','C','C','D','E','E','X'},     // backwater
                     {'A','A','A','B','B','C','C','D','E','E','X'},     // standard
                     {'A','A','A','B','B','C','C','D','E','E','E'},     // mature
                     {'A','A','A','A','B','B','C','C','D','E','X'}};    // cluster
  
  SubsectorTraffic(){
    current = 1;   // "Standard"
  }
  
  void next(){
    current++;
    current %= labels.length;
  }
  
  char getStarport(int _dieThrow){
    return values[current][_dieThrow - 2];   // die throw range is 2-12, but arrays are 0-10
  }
}