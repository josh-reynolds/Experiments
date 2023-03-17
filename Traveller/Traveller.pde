// Traveller subsector generator
//  to start with, we'll implement the version from Book 3 (Classic Traveller)
// ------------------------------------------------
// TO DO:
//  * DONE World names
//  *      Travel zones (not present in 1e)
//  *      Jump routes (only present in 1e)
//  *      Saving subsector for print
//  * DONE Single-page view
//  *      Print-friendly color scheme / alternate schemes
//  *      Saving/loading subsectors / data format
//  *      'Character' location and movement / ships (and UI elements)
//  *      Trade system
//  *      Sectors and multi-subsector layouts / 'infinite' space
//  *      Moving beyond 1e...
// ------------------------------------------------
// Hex geometry and layout
// 
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
// ------------------------------------------------

int hexRadius = 32;
int border = hexRadius;

float yOffset = sqrt((hexRadius * hexRadius) - (hexRadius/2 * hexRadius/2));
int startX = hexRadius + border;
int startY = (int)yOffset + border;
  
ArrayList<System> subsector;
int vertCount = 10;
int horzCount = 8;

String wordFile = "words.txt";
String lines[];

void setup(){
  // calculated per metrics above, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  
  background(255);
 
  subsector = new ArrayList<System>();
  lines = loadStrings(wordFile);
  
  for (int j = 1; j <= horzCount; j++){
    for (int i = 1; i <= vertCount; i++){      
      Coordinate coord = new Coordinate(j, i);
      subsector.add(new System(coord));
    }
  }
  
  int textPanelLeft = width/2 + border;
  int textLine = border;
  PFont font = loadFont("Consolas-12.vlw");
  
  for (System s : subsector){
    s.show();
    
    if (s.occupied){
      println(s);

      textAlign(LEFT, TOP);
      fill(0);
      textFont(font, 12);    
      text(s.toString(), textPanelLeft, textLine);    
      textLine += 14;
    }
  }
  
  for (System s : subsector){
    if (s.occupied){ s.showName(); }
  }
}

// loop & geometry are 0-based, but coordinates are 1-based
// so have adjustments in these functions to reconcile

float getX(int _xCoord){
  return startX + (_xCoord - 1) * (hexRadius * 1.5);
}

float getY(int _yCoord, int _xCoord){
  float columnAdjust;
  if ((_xCoord - 1) % 2 == 0){
    columnAdjust = 0;
  } else {
    columnAdjust = yOffset;
  }
  
  return startY + (yOffset * (_yCoord - 1) * 2) + columnAdjust;
}

int oneDie(){
  return floor(random(0,6)) + 1;
}

int twoDice(){
  return oneDie() + oneDie();
}