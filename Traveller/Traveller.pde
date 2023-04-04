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
//  * DONE Beautify menu screen
//  * DONE Intercept non-JSON file selection
//  * FIX  BUG: image save is capturing the menu screen when creating a new subsector
//  * DONE Reference to Routes in Systems
//  * FIX  BUG: routes are being duplicated - generated from both directions
//  * FIX  BUG: after button click, any mouse clicks on the canvas repeat the last action
//  * DONE Subsector summary paragraph
//  * DONE Summary as class field generated in ctor and persisted via JSON
//  * DONE Better (i.e. any) UI/mechanic for changing color schemes
//  * DONE Menu item to select color scheme
//  * DONE REFACTOR: move presentation details out of main script
//  * DONE Construct hex display once and show cached image
//  * DONE REFACTOR: consolidate polygon-drawing routines
//  *      Validating JSON data
//  *      Alternate text format to facilitate input (CSV?)
//  *      Mechanism to force saving/overwrite (e.g. if JSON has been manually edited)
//  *      Proper layering of hex display
//  *      Separate hex display from system list display
//  *      'Character' location and movement / ships (and UI elements)
//  *      Trade system
//  *      Sectors and multi-subsector layouts / 'infinite' space
//  *      Moving beyond 1e...
//  *      Support for multiple rulesets
//  *      Travel zones (not present in 1e)
//  *      Detailed systems/worlds
//  *      Subsector statistics (pop distribution etc.)
//  *      SIDE PROJECT: statistical analysis of large numbers of UWPs, per ruleset
//  *      BUG: panel can't show more than 44 systems, truncating subsector listing
//  *      REFACTOR: move utility functions out of main script
//  *      REFACTOR: consolidate duplicate code in file handling
// ------------------------------------------------
import java.util.Map;
import java.util.LinkedHashMap;

int hexRadius = 32;
int border = hexRadius;

String wordFile = "words.txt";
String lines[];

ColorScheme scheme;

Subsector subs;
SubsectorDisplay subD;
Boolean loading = true;

Button[] buttons;
String mode;
String jsonFile = "";

void setup(){
  // calculated per metrics detailed in SubsectorDisplay, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  

  lines = loadStrings(wordFile);

  scheme = new ColorScheme(loadJSONObject(".\\data\\DefaultColors.json"));

  subD = new SubsectorDisplay();

  buttons = new Button[3];
  buttons[0] = new Button("New", 32, border, border * 4);
  buttons[1] = new Button("Load", 32, border, border * 6);
  buttons[2] = new Button("Colors", 32, border, border * 8);
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
  background(scheme.menuBackground);
  
  int titleSize = 72;
  textSize(titleSize);
  textAlign(LEFT, TOP);
  fill(scheme.menuTitle);
  String title = "TRAVELLER";
  float titleWidth = textWidth(title);
  text(title, width - titleWidth - border, border);
  
  textSize(titleSize/2);
  textAlign(LEFT, TOP);
  fill(scheme.menuText);
  String subtitle = "Subsector Generator";
  float subtitleWidth = textWidth(subtitle);
  text(subtitle, width - subtitleWidth - border, titleSize + border);
  
  strokeWeight(10);
  stroke(scheme.menuTitle);
  line(0, border, width, border);
  
  for (Button b : buttons){
    b.mouseHover();
    b.show();
  }
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
    buttons[0].highlight = false;
    loading = false;
    subs = createSubsector();
    mode = "display";
    drawScreen();
    writeImage();
    writeText();
    writeJSON();
  }
  
  if (buttons[1].highlight){ 
    println(buttons[1].label);
    selectInput("Select a subsector json file to load.", "subsectorFileSelected", dataFile(".\\output\\*.json"));
    // this filters, though the dialog "Files of Type" box doesn't reflect that fact
    // and if you type "*.txt" in the selection box, for instance, it will change the hidden filter in use
    // see https://discourse.processing.org/t/selectinput-i-like-to-tell-it-the-folder-to-use/13703/10
  }
  
  if (buttons[2].highlight){
    println(buttons[2].label);
    selectInput("Select a color json file to load.", "colorFileSelected", dataFile(".\\data\\*.json"));
  }
}

void colorFileSelected(File _selection){
  if (_selection == null){
    println("Please select a json file, or choose NEW.");
    return;
  }
  String fileName = _selection.toString();
  int fl = fileName.length();
  String extension = fileName.substring(fl-4,fl).toLowerCase();

  if (!extension.equals("json")){
    println("Please select a json file, or choose NEW.");
  } else {
    println(_selection);
    scheme = new ColorScheme(loadJSONObject(fileName));
    buttons[2].highlight = false;
    mode = "menu";
  }
}

void subsectorFileSelected(File _selection){
  if (_selection == null){
    println("Please select a json file, or choose NEW.");
    return;
  }
  jsonFile = _selection.toString();
  int fl = jsonFile.length();
  String extension = jsonFile.substring(fl-4,fl).toLowerCase();

  if (!extension.equals("json")){
    println("Please select a json file, or choose NEW.");
  } else {
    println(_selection);
    loading = true;
    subs = createSubsector();
    println(subs.summary);
    buttons[1].highlight = false;
    mode = "display";
  }
}

void drawScreen(){
  // I think this will expand out again, so leaving this func instead of inlining
  subD.show(subs);
}

void writeImage(){
  String imageFileName = ".\\output\\" + subs.name + "-###.png";
  saveFrame(imageFileName);
}

void writeText(){
  String textFileName = ".\\output\\" + subs.name + ".txt";
  PrintWriter output = createWriter(textFileName);
  output.println(subs.name);
  output.println();
  output.println(subs.summary);
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
  
  println(subs.summary);
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