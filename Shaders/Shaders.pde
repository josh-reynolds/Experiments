// Implementing cellular noise from this paper:
//   https://thebookofshaders.com/12/

// --------------------------------------------------------
// Overall problem: how to tesselate a canvas with random concave polygons
// So far have pursued following with limited success (in other sketches):
//  - bounding ellipse solution runs into complexity, not sure viability
//  - create a graph of connected nodes, then draw borders at midpoints
//      haven't abandoned this yet
//  - Photoshop 'stained glass filter' gives the right look, quick search 
//      turned up this paper. Giving it a go.
// --------------------------------------------------------

// my initial approach was to mimic the algorithm using standard Processing
//  per-pixel operations in a loop
// the 'Book of Shaders' includes a method to run shaders properly via
//  Processing, however: https://thebookofshaders.com/04/
// giving that a try

//PShader shader;

PVector[] points;
int pointCount = 6;

void setup(){
  size(400, 400, P2D);
  
  //shader = loadShader("shader.frag");
  
  points = new PVector[pointCount];
  for (int i = 0; i < pointCount; i++){
    points[i] = new PVector(random(width), random(height));
  }
}

void draw(){
  //shader.set("u_resolution", float(width), float(height));
  //shader.set("u_mouse", float(mouseX), float(mouseY));
  //shader.set("u_time", millis() / 1000.0);
  //shader(shader);
  //rect(0, 0, width, height);
  
  loadPixels();
  for (int x = 0; x < width; x++){
    for (int y = 0; y < height; y++){
      float minDistance = width;

      for (int i = 0; i < pointCount; i++){
        minDistance = min(minDistance, PVector.dist(points[i], new PVector(x,y))); 
      }
      
      // distance field
      color c = color(map(minDistance,0,width,0,255));     
      
      // isolines - not getting same result as sample
      float threshold = 0.7;
      minDistance = map(minDistance, 0, width, 0, 1); 
      float value = abs(sin(50.0 * minDistance));
      float result = step(threshold, value) * 0.3;
      c -= result;
      
      int index = x + (y * width); 
      pixels[index] = c;
    }
  }
  updatePixels();
}

void mouseMoved(){
  points[pointCount - 1] = new PVector(mouseX, mouseY);
}

float step(float threshold, float value){
  if (value < threshold){
    return 0.0;
  } else {
    return 1.0;
  }
}