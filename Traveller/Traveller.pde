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
Boolean loading = true;

String mode;
Menu menu;
Display display;

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
  menu = new Menu();
  display = new Display();
  tests = new TestSuite();  
  mode = "menu";
}

void draw(){
  if (mode.equals("menu")){     // pushing towards polymorphic design so we can just say something like "mode.drawScreen()"
    menu.drawScreen();
  } else if (mode.equals("display")){
    display.drawScreen();
  }
}

void mouseClicked(){
  menu.mouseClicked();
}