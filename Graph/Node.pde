class Node {
  PVector pos;
  ArrayList<Node> neighbors;
  color col;
  int neighborCount;
  
  Node(int _x, int _y, boolean _createNeighbors){
    if (debug){ println("ctor: " + _createNeighbors); }
    pos = new PVector(_x, _y);
    neighbors = new ArrayList<Node>();
    col = color(255);
    neighborCount = floor(random(5, 8));
    
    if (_createNeighbors){  
      float angularSpread = TWO_PI / neighborCount;
      float startAngle = random(TWO_PI);
      
      if (debug){ println(); println("creating neighbors"); }
      // floating point precision issue here was sometimes creating an extra node
      //  at the end of the list - subtracting 1 degree from the end case fixes it
      for (float a = startAngle; a < TWO_PI + startAngle - radians(1); a += angularSpread){
        if (debug){ 
          println("angle = " + degrees(a));
          println("end = " + degrees(TWO_PI + startAngle));
          println("next = " + degrees(a + angularSpread));
        }
        int x = int(100 * cos(a) + pos.x);
        int y = int(100 * sin(a) + pos.y);
        addNeighbor(new Node(x, y, false));
      }
      
      if (debug){ println(); println("linking neighbors: " + neighbors.size()); }
      for (int i = 0; i < neighbors.size() - 1; i++){
        neighbors.get(i).addNeighbor(neighbors.get(i+1));
      }
      neighbors.get(0).addNeighbor(neighbors.get(neighbors.size()-1));
      
      if (debug && neighborCount != neighbors.size()){ println("NEIGHBOR ERROR - expected: " + neighborCount + 
                                                               " received: " + neighbors.size()); }    
    }
  }

  Node(int _x, int _y){
    this(_x, _y, true);
    if (debug){ println("Root ctor: " + this); }
  }
  
  void addNeighbor(Node _n, boolean _bidi){
    if (debug){ println("Add neighbor: " + _n + " : " + _bidi); }
    neighbors.add(_n);
    if (_bidi){
      _n.addNeighbor(this, false);
    }
  }
  
  void addNeighbor(Node _n){
    if (debug){ println("wrapper"); }
    addNeighbor(_n, true);
  }
  
  void show(){
    show(true);
  }
  
  void show(boolean _bidi){
    fill(col);
    ellipse(pos.x, pos.y, 10, 10);

    for (Node n : neighbors){
      line(pos.x, pos.y, n.pos.x, n.pos.y);
      if (_bidi){
        n.show(false);
      }
    }
  }
}