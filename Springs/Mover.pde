class Mover{
  PVector pos;
  PVector vel;
  color c;
  int diameter;
  
  Mover(PVector _pos){
    pos = _pos;
    vel = new PVector(0,0);
    c = color(random(255), random(255), random(255), 150);
    diameter = 20;
  }
  
  void update(){
    edges();
    pos.add(vel);
  }
  
  void applyForce(PVector f){
    vel.add(f);
    vel.mult(0.95);
  }
  
  void edges(){
    if (pos.y <= 0 || pos.y >= height){
      vel.y = vel.y * -1;
    }
    if (pos.x <= 0 || pos.x >= width){
      vel.x = vel.x * -1;
    }
    if ((pos.y > height - diameter/2) && (vel.mag() < 0.8)){
      vel.setMag(0);
    }
  }
  
  void show(){
    fill(c);
    //noStroke();
    ellipse(pos.x, pos.y, diameter, diameter); 
  }
}