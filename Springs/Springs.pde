

ArrayList<Mover> movers;
ArrayList<Spring> springs;
PVector gravity;
int count = 15;

void setup(){
  size(400, 400);
  
  movers = new ArrayList<Mover>();
  for (int i = 0; i < count; i++){
    movers.add(new Mover(new PVector(random(width), random(height)))); 
  }
  
  springs = new ArrayList<Spring>();
  for (int i = 0; i < count-2; i++){
    springs.add(new Spring(movers.get(i), movers.get(i+1), floor(random(75,125))));
    springs.add(new Spring(movers.get(i), movers.get(i+2), floor(random(75,125))));
  }
  
  gravity = new PVector(0, 0.2);
  
  //frameRate(3);
}

void draw(){
  background(100);
  
  for (Spring s : springs){
    s.update();
  }

  for (Mover m : movers){
    m.applyForce(gravity);
    m.update();
  }
  
  for (Spring s : springs){
    s.show();
  }
  
  for (Mover m : movers){
    m.show();
  }
}