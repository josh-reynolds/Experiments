

// visualizing orbits in a Traveller system

// TO_DO
//  DONE orbiting bodies
//  DONE motion
//       satellites of satellites
//       proper velocities
//       variable body size
//       primary/companion size & color
//       planetoid belt graphics

float[] orbits = {1, 2, 3, 4.3, 6, 9, 13, 14, 17, 22};
OrbitDisplay[] display;
int maxPixelDiameter;
float maxOrbitValue = 0;
float scaleFactor;
 

void setup(){
  size(400, 400);
  background(255);
  
  maxPixelDiameter = min(width/2, height/2);
  println("Maximum pixel dimension: " + maxPixelDiameter);
  
  // find the largest orbit to establish scale
  for (int i = 0; i < orbits.length; i++){
    float candidate = orbits[i];
    if (candidate > maxOrbitValue){ maxOrbitValue = candidate; }
  }
  println("Maximum orbit in this set is: " + maxOrbitValue);
  
  scaleFactor = 2 * maxPixelDiameter/maxOrbitValue;
  println("Scale factor = " + scaleFactor);

  display = new OrbitDisplay[orbits.length];
  for (int i = 0; i < display.length; i++){
    float d = orbits[i] * scaleFactor;
    display[i] = new OrbitDisplay(new PVector(width/2, height/2), d);
  }
}

void draw(){
  background(255);
  
  stroke(0);
  fill(255, 255, 0);
  ellipse(width/2, height/2, 10, 10);

  for (OrbitDisplay od : display){
    od.update();
    od.display();
  }
}

class OrbitDisplay {
  float angle;
  float diameter;
  PVector center;
  
  OrbitDisplay(PVector _center, float _diameter){
    center = _center;
    diameter = _diameter;
    angle = random(0, TWO_PI);
  }
  
  void update(){
    angle += 0.01;
  }
  
  void display(){
    noFill();
    stroke(100);
    strokeWeight(0.5);
    ellipse(center.x, center.y, diameter, diameter);
    
    float dx = (diameter/2 * cos(angle)) + center.x;
    float dy = (diameter/2 * sin(angle)) + center.y;
    
    fill(0);
    ellipse(dx, dy, 5, 5);
  } 
}