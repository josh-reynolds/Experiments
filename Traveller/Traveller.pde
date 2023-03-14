// Traveller subsector generator
//  to start with, we'll implement the version from Book 3 (Classic Traveller)



// hex x,y is center
// hexRadius is distance from center to each vertex
//   it is also the length of each side
// yOffset is distance from center to edge (via Pythagoras) 

// hex height                        = 2 x yOffset
// vertical offset (same column)     = hex height
// vertical offset (adjacent column) = hex height / 2 = yOffset
// horizontal offset                 = hexRadius * 1.5 (equilateral triangles)

// TOTAL WIDTH  = (2 x border) + (2 x hexRadius) + ((horzCount - 1) x hexRadius x 1.5)
// TOTAL HEIGHT = (2 x border) + (((2 x vertCount) + 1) x yOffset

//println((2 * border) + (2 * hexRadius) + ((horzCount - 1) * hexRadius * 1.5));
//println((2 * border) + (((2 * vertCount) + 1) * yOffset));
 
int hexRadius = 32;
int border = hexRadius;

float yOffset = sqrt((hexRadius * hexRadius) - (hexRadius/2 * hexRadius/2));
int startX = hexRadius + border;
int startY = (int)yOffset + border;
  
ArrayList<Hex> subsector;

int vertCount = 10;
int horzCount = 8;

void setup(){
  size(464, 646);
  background(255);
 
  subsector = new ArrayList<Hex>();
  
  for (int i = 0; i < vertCount; i++){
    for (int j = 0; j < horzCount; j++){      
      float x = getX(j);
      float y = getY(i, j);
      subsector.add(new Hex(x, y, hexRadius, color(0)));
    }
  }
  
  for (Hex h : subsector){
    h.show();
  }
}

float getX(int _xCoord){
  return startX + _xCoord * (hexRadius * 1.5);
}

float getY(int _yCoord, int _xCoord){
  float columnAdjust;
  if (_xCoord % 2 == 0){
    columnAdjust = 0;
  } else {
    columnAdjust = yOffset;
  }
  
  return startY + (yOffset * _yCoord * 2) + columnAdjust;
}