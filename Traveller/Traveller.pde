// Traveller subsector generator
//  to start with, we'll implement the version from Book 3 (Classic Traveller)
// ------------------------------------------------
// TO DO:
//  * DONE World names
//  * DONE Saving subsector for print
//  * DONE Single-page view
//  * DONE Print-friendly color scheme / alternate schemes
//  * DONE Calculate distance between two hexes
//  * DONE Jump routes (only present in 1e)
//  * DONE List out all routes
//  * DONE Text file output
//  * DONE Display subsector name on page
//  *      Proper layering of hex display
//  *      Better (i.e. any) UI/mechanic for changing color schemes
//  * .... Saving/loading subsectors / data format
//  *      Reference to Routes in Systems
//  *      'Character' location and movement / ships (and UI elements)
//  *      Trade system
//  *      Sectors and multi-subsector layouts / 'infinite' space
//  *      Moving beyond 1e...
//  *      Travel zones (not present in 1e)
//  *      Subsector summary paragraph
//  *      BUG: panel can't show more than 44 systems, truncating subsector listing
//  *      REFACTOR: consolidate polygon-drawing routines
//  *      REFACTOR: move presentation details out of main script
//  *      REFACTOR: move utility functions out of main script
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

PrintWriter output;

void setup(){
  // calculated per metrics above, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  

  lines = loadStrings(wordFile);

  subsector = new ArrayList<System>();
  String subsectorName = "Subsector_" + lines[floor(random(lines.length))];
  String filename = subsectorName + ".txt";
  //output = createWriter(filename);
  //output.println(subsectorName);
  //output.println("=========================");
  
  routes = new ArrayList<Route>();

  scheme = new ColorScheme(color(0),             // Hex background
                           color(125),           // Hex outline
                           color(255, 255, 153), // World name display
                           color(0, 125, 255),   // Water presence
                           color(255),           // Hex elements
                           color(0),             // System listing
                           color(255),           // Page background
                           color(200, 80));     // Routes 

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
    s.showBackground();
  }

  calculateRoutes();
  for (Route r : routes){
    r.show();
  }
  
  textAlign(LEFT, TOP);
  fill(scheme.systemList);
  textFont(font, 24);
  text(subsectorName, textPanelLeft, textLine - 24);
  
  for (System s : subsector){
    s.showForeground();
    
    if (s.occupied){
      println(s);
      //output.println(s);
      
      textAlign(LEFT, TOP);
      fill(scheme.systemList);
      textFont(font, 12);    
      text(s.toString(), textPanelLeft, textLine);    
      textLine += 14;
    }
  }
  
  for (System s : subsector){
    if (s.occupied){ s.showName(); }
  }

  //output.println("=========================");
  for (Route r : routes){
    println(r);
    //output.println(r);
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
  
  //subsectorName += "-###.png";
  //saveFrame(subsectorName);
  //println("Saved " + subsectorName);
  //output.println("=========================");
  //output.println("Saved " + subsectorName);
  //output.flush();
  //output.close();

  JSONArray json = new JSONArray();
  for (int i = 0; i < subsector.size(); i++){
    System s = subsector.get(i);    
    if (s.occupied){
      json.setJSONObject(i, s.asJSON());
    }
  }  
  saveJSONArray(json, "test.json");  // need to tie this back to the subsector name
  
  // only save occupied systems, and only data objects,
  // not presentation, processing, display classes -
  // for System, that's hex + occupied
  // let's start with just one system
  
  // also, we only really need to care about ctor inputs or 
  // non-deterministic/stochastic fields - TradeClass can be 
  // perfectly recreated from a given UWP
  
  // I expect JSON is going to get pretty verbose when we push out
  // all 40-50 systems, but it has the advantage of being human
  // readable and editable
  
  // Systems look good - need to get Routes next
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

void calculateRoutes(){
  for (int i = 0; i < subsector.size(); i++){
    System candidate = subsector.get(i);
    if (!candidate.occupied || candidate.uwp.starport == 'X'){ continue; }
    
    for (int j = i + 1; j < subsector.size(); j++){
      System target = subsector.get(j);
      if (!target.occupied || target.uwp.starport == 'X'){ continue; }
      
      int dist = candidate.distanceToSystem(target);  
      if (dist > 4){ continue; }
      
      char starportA = candidate.uwp.starport;
      char starportB = target.uwp.starport;
      String pair;
      if (starportA <= starportB){ 
        pair = str(starportA) + str(starportB); 
      } else {
        pair = str(starportB) + str(starportA);
      }

      int roll = oneDie();

      // transcription of the table on p.2 of Book 3 (1st edition)
      // probably a clever way to make this shorter, refactoring opportunity
      // later perhaps
      if (pair.equals("AA")){
        if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 2){ routes.add(new Route(candidate, target)); }
        if (dist == 3 && roll >= 4){ routes.add(new Route(candidate, target)); }
        if (dist == 4 && roll >= 5){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("AB")){
        if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 3){ routes.add(new Route(candidate, target)); }
        if (dist == 3 && roll >= 4){ routes.add(new Route(candidate, target)); }
        if (dist == 4 && roll >= 5){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("AC")){
        if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 4){ routes.add(new Route(candidate, target)); }
        if (dist == 3 && roll >= 6){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("AD")){
        if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 5){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("AE")){
        if (dist == 1 && roll >= 2){ routes.add(new Route(candidate, target)); }
      }

      if (pair.equals("BB")){
        if (dist == 1 && roll >= 1){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 3){ routes.add(new Route(candidate, target)); }
        if (dist == 3 && roll >= 4){ routes.add(new Route(candidate, target)); }
        if (dist == 4 && roll >= 6){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("BC")){
        if (dist == 1 && roll >= 2){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 4){ routes.add(new Route(candidate, target)); }
        if (dist == 3 && roll >= 6){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("BD")){
        if (dist == 1 && roll >= 3){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 6){ routes.add(new Route(candidate, target)); }  
      }
      if (pair.equals("BE")){
        if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
      }
      
      if (pair.equals("CC")){
        if (dist == 1 && roll >= 3){ routes.add(new Route(candidate, target)); }
        if (dist == 2 && roll >= 6){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("CD")){
        if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("CE")){
        if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
      }
      
      if (pair.equals("DD")){
        if (dist == 1 && roll >= 4){ routes.add(new Route(candidate, target)); }
      }
      if (pair.equals("DE")){
        if (dist == 1 && roll >= 5){ routes.add(new Route(candidate, target)); }
      }
      
      if (pair.equals("EE")){
        if (dist == 1 && roll >= 6){ routes.add(new Route(candidate, target)); }
      }
    }
  }
}