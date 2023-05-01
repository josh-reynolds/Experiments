// Traveller subsector generator
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
  buttons[0] = new Button("New", 32, border, border * 4, new NewSubsector());
  buttons[1] = new Button("Load", 32, border, border * 6, new Load());
  buttons[2] = new Button("Colors", 32, border, border * 8, new ChangeColors());
  buttons[3] = new Button("Rules", 32, border, border * 10, new ChangeRules());
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
  for (Button b : buttons){
    if (b.highlight){ b.run(); }
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