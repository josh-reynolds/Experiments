class Route {
  System s1;
  System s2;
  
  Route(System _s1, System _s2){
    s1 = _s1;
    s2 = _s2;
  }
  
  void show(){
    stroke(scheme.routes);
    strokeWeight(6);
    line(s1.hex.x, s1.hex.y, s2.hex.x, s2.hex.y);
  }
}