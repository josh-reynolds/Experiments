

// visualizing orbits in a Traveller system

// TO_DO
//  orbiting bodies
//  motion
//  satellites of satellites


float[] orbits = {1, 2, 3, 4.3, 6, 9, 13, 14, 17, 22};
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
}

void draw(){
  stroke(0);
  fill(0);
  ellipse(width/2, height/2, 5, 5);
    
  noFill();
  stroke(100);
  strokeWeight(0.5);
  for (int i = 0; i < orbits.length; i++){
    float diameter = orbits[i] * scaleFactor;
    ellipse(width/2, height/2, diameter, diameter);
  }  
}