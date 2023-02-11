class Node {
  PVector pos;
  ArrayList<Node> neighbors;
  
  Node(int _x, int _y, boolean _createNeighbors){
    if (debug){ println("ctor: " + _createNeighbors); }
    pos = new PVector(_x, _y);
    neighbors = new ArrayList<Node>();
       
    if (_createNeighbors){
      int neighborCount = floor(random(5, 8));
      float angularSpread = TWO_PI / neighborCount;
      float startAngle = random(TWO_PI);
      
      if (debug){ println(); println("creating neighbors"); }
      for (float a = startAngle; a < TWO_PI + startAngle; a += angularSpread){
        int x = int(100 * cos(a) + pos.x);
        int y = int(100 * sin(a) + pos.y);
        addNeighbor(new Node(x, y, false));
      }
      
      if (debug){ println(); println("linking neighbors: " + neighbors.size()); }
      for (int i = 0; i < neighbors.size() - 1; i++){
        neighbors.get(i).addNeighbor(neighbors.get(i+1));
      }
      neighbors.get(0).addNeighbor(neighbors.get(neighbors.size()-1));
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
    ellipse(pos.x, pos.y, 10, 10);

    for (Node n : neighbors){
      line(pos.x, pos.y, n.pos.x, n.pos.y);
      if (_bidi){
        n.show(false);
      }
    }
  }
}