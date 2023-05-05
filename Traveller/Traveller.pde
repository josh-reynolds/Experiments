// Traveller subsector generator
// ------------------------------------------------
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.TreeMap;

int hexRadius = 32;
int border = hexRadius;

String wordFile = "words.txt";
String lines[];

ColorScheme scheme;

Subsector subs;
Boolean loading = true;

Screen screen;

Ruleset ruleset;
String[] rules = {"CT77", "CT81", "Scouts (Extended)"};
int currentRules = 0;

TestSuite tests;
int debug = 2;

void setup(){
  // calculated per metrics detailed in SubsectorDisplay, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  
  lines = loadStrings(wordFile);
  scheme = new ColorScheme(loadJSONObject(".\\data\\DefaultColors.json"));
  ruleset = new Ruleset(rules[currentRules]);
  tests = new TestSuite();  
  screen = new Menu();
}

void draw(){
  screen.drawScreen();
}

void mouseClicked(){
  screen.mouseClicked();
}