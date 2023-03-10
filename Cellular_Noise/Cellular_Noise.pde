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

PVector[] points;
int pointCount = 6;

void setup(){
  size(400, 400);
  
  points = new PVector[pointCount];
  for (int i = 0; i < pointCount; i++){
    points[i] = new PVector(random(width), random(height));
  }
}

void draw(){
  loadPixels();
  for (int x = 0; x < width; x++){
    for (int y = 0; y < height; y++){
      float minDistance = width;

      for (int i = 0; i < pointCount; i++){
        minDistance = min(minDistance, PVector.dist(points[i], new PVector(x,y)));
      }

      // distance field
      color c = color(map(minDistance, 0, width, 0, 255));     
      
      // isolines
      // sample shader uses normalized color & coordinates values, need to keep that in mind
      float threshold = 0.7;
      float value = abs(sin(50.0 * minDistance / width));
      float result = step(threshold, value) * 0.3 * 255;

      // c -= result;    // works, but shifts into blue values
      float red = red(c) - result;
      float green = green(c) - result;
      float blue = blue(c) - result;
      c = color(red, green, blue);
      
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