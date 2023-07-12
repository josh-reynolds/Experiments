class StarBuilder {
  StarBuilder(){}
  
  Star newStar(System _parent){
    Star s = new Star(_parent);
    //s.createSatellites();    // need to untangle references, getting null pointer from generateType() on companion stars
    return s;
  }
}