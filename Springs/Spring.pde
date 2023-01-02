class Spring{
  Mover a, b;
  int l;
  float strength;
  
  Spring(Mover _a, Mover _b, int _l){
    a = _a;
    b = _b;
    l = _l;
    strength = 0.333;
  }
  
  void show(){
    stroke(0,150);
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y); 
  }
  
  void update(){
    float currentLength = PVector.dist(a.pos,b.pos);
    
    PVector aToB = PVector.sub(a.pos, b.pos).normalize();
    PVector bToA = PVector.sub(b.pos, a.pos).normalize();
       
    float magnitude = currentLength / l;
    aToB.mult(magnitude * strength);
    bToA.mult(magnitude * strength);
    
    if (currentLength > l){   
       a.applyForce(bToA);
       b.applyForce(aToB);
    }
    if (currentLength < l){   
       a.applyForce(aToB);
       b.applyForce(bToA);
    }    
  }
}