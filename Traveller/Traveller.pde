// Traveller subsector generator
//  to start with, we'll implement the version from Book 3 (Classic Traveller)
// ------------------------------------------------
// TO DO:
//  * DONE World names
//  *      Travel zones (not present in 1e)
//  *      Jump routes (only present in 1e)
//  * DONE Saving subsector for print
//  * DONE Single-page view
//  * DONE Print-friendly color scheme / alternate schemes
//  *      Better (i.e. any) UI/mechanic for changing color schemes
//  *      Saving/loading subsectors / data format
//  *      'Character' location and movement / ships (and UI elements)
//  *      Trade system
//  *      Sectors and multi-subsector layouts / 'infinite' space
//  *      Moving beyond 1e...
//  *      BUG: panel can't show more than 44 systems, truncating subsector listing
//  *      REFACTOR: consolidate polygon-drawing routines
//  *      REFACTOR: move presentation details out of main script
//  *      Display subsector name on page
//  *      REFACTOR: move utility functions out of main script
//  * DONE Calculate distance between two hexes
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

ArrayList<Route> routes;

String wordFile = "words.txt";
String lines[];

ColorScheme scheme;

void setup(){
  // calculated per metrics above, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  

  subsector = new ArrayList<System>();
  routes = new ArrayList<Route>();
  lines = loadStrings(wordFile);
  
  scheme = new ColorScheme(color(0),             // Hex background
                           color(125),           // Hex outline
                           color(255, 255, 153), // World name display
                           color(0, 125, 255),   // Water presence
                           color(255),           // Hex elements
                           color(0),             // System listing
                           color(255),           // Page background
                           color(200, 125));     // Routes 

  background(scheme.pageBackground);
  
  for (int j = 1; j <= horzCount; j++){
    for (int i = 1; i <= vertCount; i++){      
      Coordinate coord = new Coordinate(j, i);
      subsector.add(new System(coord));
    }
  }

  fill(scheme.cellOutline);
  rect(0, 0, width/2, height);
  
  int textPanelLeft = width/2 + border;
  int textLine = border;
  PFont font = loadFont("Consolas-12.vlw");
  
  for (System s : subsector){
    s.show();
    
    if (s.occupied){
      println(s);

      textAlign(LEFT, TOP);
      fill(scheme.systemList);
      textFont(font, 12);    
      text(s.toString(), textPanelLeft, textLine);    
      textLine += 14;
    }
  }
  
  routes.add(new Route(subsector.get(floor(random(subsector.size()))),
                       subsector.get(floor(random(subsector.size())))));
  
  for (Route r : routes){
    r.show();
  }
  
  for (System s : subsector){
    if (s.occupied){ s.showName(); }
  }

  // displaying distance calculation for test purposes
  // helps to suppress other cell contents to make this more visible...
  //System target = subsector.get(floor(random(subsector.size())));
  //for (System s : subsector){
  //  textSize(20);
  //  fill(scheme.worldName);
  //  textAlign(CENTER, CENTER);
  //  text(s.distanceToSystem(target), s.hex.x, s.hex.y);
  //}
  
  // Random name for now to prevent overwriting
  String subsectorName = "Subsector_" + lines[floor(random(lines.length))];
  subsectorName += "-###.png";
  saveFrame(subsectorName);
  println("Saved " + subsectorName);
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