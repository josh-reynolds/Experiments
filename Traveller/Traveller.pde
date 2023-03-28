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
//  * DONE Saving subsectors / data formats
//  * DONE Create an output folder
//  * DONE Writing out coords in JSON for null systems (need for loading)
//  * DONE Coordinate equality
//  * DONE REFACTOR: move coordinate conversion methods to System class
//  * DONE REFACTOR: introduce subsector class
//  * DONE REFACTOR: consolidate & clean up output code
//  * DONE REFACTOR: consolidate screen drawing code
//  * DONE REFACTOR: asJSON method for Subsector class
//  * DONE Coordinate ctor that consumes JSON data
//  * DONE More JSON ctors: UWP, System
//  * DONE Adding subsector name to JSON
//  * DONE Lookup of Systems by Coordinate (need for Routes)
//  * DONE Route ctor that consumes JSON data
//  * DONE Subsector ctor that consumes JSON data
//  * DONE Loading subsectors
//  * DONE Suppress saving/overwrite if loading existing data 
//  * FIX  BUG: text panel, file and JSON system lists are unordered due to HashMap iterator
//  * DONE Shift display to draw()
//  * DONE Mode selection - new vs. load (screen?)
//  * DONE File selection dialog for loading
//  *      Intercept non-JSON file selection
//  *      Beautify menu screen
//  *      Validating JSON data
//  *      Alternate text format to facilitate input (CSV?)
//  *      Proper layering of hex display
//  *      Construct hex display once and show cached image
//  *      Better (i.e. any) UI/mechanic for changing color schemes
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
import java.util.Map;
import java.util.LinkedHashMap;

int hexRadius = 32;
int border = hexRadius;

float yOffset = sqrt((hexRadius * hexRadius) - (hexRadius/2 * hexRadius/2));
int startX = hexRadius + border;
int startY = (int)yOffset + border;

String wordFile = "words.txt";
String lines[];

ColorScheme scheme;

Subsector subs;
Boolean loading = true;

Button[] buttons;
String mode;
String jsonFile = "";

void setup(){
  // calculated per metrics above, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  

  lines = loadStrings(wordFile);

  scheme = new ColorScheme(color(0),             // Hex background
                           color(125),           // Hex outline
                           color(255, 255, 153), // World name display
                           color(0, 125, 255),   // Water presence
                           color(255),           // Hex elements
                           color(0),             // System listing
                           color(255),           // Page background
                           color(200, 80),       // Routes
                           color(255, 0, 0));    // Button highlight 

  buttons = new Button[2];
  buttons[0] = new Button("New", 32, border, border * 3);
  buttons[1] = new Button("Load", 32, border, border * 5);
  mode = "menu";
}

void draw(){
  if (mode.equals("menu")){
    drawMenu();
  } else if (mode.equals("display")){
    drawScreen();
  }
}

void drawMenu(){
  background(scheme.pageBackground);
  textSize(48);
  textAlign(LEFT, TOP);

  fill(scheme.systemList);
  text("Traveller subsector generator", border, border);
  
  buttons[0].mouseHover();
  buttons[0].show();
  
  buttons[1].mouseHover();
  buttons[1].show();
}

Subsector createSubsector(){
  if (loading){
    JSONObject subsectorData = loadJSONObject(jsonFile);
    return new Subsector(subsectorData);
  } else {
    return new Subsector();
  }
}

void mouseClicked(){
  if (buttons[0].highlight){ 
    println(buttons[0].label);
    loading = false;
    subs = createSubsector();
    writeImage();
    writeText();
    writeJSON();
    mode = "display";
  }
  
  if (buttons[1].highlight){ 
    println(buttons[1].label);
    selectInput("Select a subsector json file to load.", "fileSelected");
  }
}

void fileSelected(File _selection){
  if (_selection == null){
    println("Please select a json file, or choose NEW.");
  } else {
    println(_selection);
    jsonFile = _selection.toString();
    loading = true;
    subs = createSubsector();
    mode = "display";
  }
}

void drawScreen(){
  background(scheme.pageBackground);

  fill(scheme.cellOutline);
  rect(0, 0, width/2, height);
  
  int textPanelLeft = width/2 + border;
  int textLine = border;
  PFont font = loadFont("Consolas-12.vlw");
  
  for (System s : subs.systems.values()){
    s.showBackground();
  }

  for (Route r : subs.routes){
    r.show();
  }
  
  textAlign(LEFT, TOP);
  fill(scheme.systemList);
  textFont(font, 24);
  text(subs.name, textPanelLeft, textLine - 24);
  
  for (System s : subs.systems.values()){
    s.showForeground();
    
    if (s.occupied){      
      textAlign(LEFT, TOP);
      fill(scheme.systemList);
      textFont(font, 12);    
      text(s.toString(), textPanelLeft, textLine);    
      textLine += 14;
    }
  }
  
  for (System s : subs.systems.values()){
    if (s.occupied){ s.showName(); }
  }
}

void writeImage(){
  String imageFileName = ".\\output\\" + subs.name + "-###.png";
  saveFrame(imageFileName);
}

void writeText(){
  String textFileName = ".\\output\\" + subs.name + ".txt";
  PrintWriter output = createWriter(textFileName);
  output.println(subs.name);
  output.println("=========================");
  
  for (System s : subs.systems.values()){    
    if (s.occupied){
      println(s);
      output.println(s);
    }
  }
  
  output.println("=========================");
  for (Route r : subs.routes){
    println(r);
    output.println(r);
  }
  
  println("Saved " + subs.name);
  output.println("=========================");
  output.println("Saved " + subs.name);
  output.flush();
  output.close();
}

void writeJSON(){
  String jsonFileName = ".\\output\\" + subs.name + ".json";
  saveJSONObject(subs.asJSON(), jsonFileName);
}

int oneDie(){
  return floor(random(0,6)) + 1;
}

int twoDice(){
  return oneDie() + oneDie();
}