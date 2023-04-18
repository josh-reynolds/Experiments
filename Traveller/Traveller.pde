// Traveller subsector generator
//  to start with, we'll implement the version from Book 3 (Classic Traveller)
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
TextPanel textPanel;
Boolean loading = true;

Button[] buttons;
String mode;
String jsonFile = "";

Ruleset ruleset;
String[] rules = {"CT77", "CT81", "Scouts (Extended)"};
int currentRules = 0;

TestSuite tests;

void setup(){
  // calculated per metrics detailed in SubsectorDisplay, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  

  lines = loadStrings(wordFile);

  scheme = new ColorScheme(loadJSONObject(".\\data\\DefaultColors.json"));

  ruleset = new Ruleset(rules[currentRules]);

  subD = new SubsectorDisplay();
  textPanel = new TextPanel();
  
  tests = new TestSuite();
  
  buttons = new Button[4];
  buttons[0] = new Button("New", 32, border, border * 4);
  buttons[1] = new Button("Load", 32, border, border * 6);
  buttons[2] = new Button("Colors", 32, border, border * 8);
  buttons[3] = new Button("Rules", 32, border, border * 10);
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
  
  fill(scheme.menuDescriptions);
  String colorSchemeDescription = "Color scheme: " + scheme.name;
  float colorSchemeDescriptionWidth = textWidth(colorSchemeDescription); 
  text(colorSchemeDescription, width - colorSchemeDescriptionWidth - border, height - titleSize - border);
  
  String rulesDescription = "Rules: " + rules[currentRules];
  float rulesDescriptionWidth = textWidth(rulesDescription);
  text(rulesDescription, width - rulesDescriptionWidth - border, height - titleSize/2 - border);
  
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
    tests.run();
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

  if (buttons[3].highlight){
    println(buttons[3].label);
    currentRules++;
    currentRules %= rules.length;
    ruleset = new Ruleset(rules[currentRules]);
  }
}

void colorFileSelected(File _selection){
  if (nullSelection(_selection)){ return; }
  if (notJSONFile(_selection)){ return; }
  println(_selection);
  
  scheme = new ColorScheme(loadJSONObject(_selection.toString()));

  buttons[2].highlight = false;
  mode = "menu";
}

void subsectorFileSelected(File _selection){
  if (nullSelection(_selection)){ return; }
  if (notJSONFile(_selection)){ return; }    
  println(_selection);
  
  jsonFile = _selection.toString();
  loading = true;
  subs = createSubsector();
  println(subs.summary);
  tests.run();

  buttons[1].highlight = false;
  mode = "display";
}

Boolean notJSONFile(File _selection){
  String fileName = _selection.toString();
  int fl = fileName.length();
  String extension = fileName.substring(fl-4,fl).toLowerCase();

  return badFileSelection(!extension.equals("json"));
}

Boolean nullSelection(File _selection){
  return badFileSelection(_selection == null);
}

Boolean badFileSelection(Boolean _condition){
  if (_condition){
    println("Please select a json file, or choose NEW.");
    return true;    
  } else {
    return false;
  }
}

void drawScreen(){
  subD.show(subs);
  textPanel.show(subs);
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
      output.println(s);
    }
  }
  
  output.println("=========================");
  for (Route r : subs.routes){
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