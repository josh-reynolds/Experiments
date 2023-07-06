// Traveller subsector generator
// ------------------------------------------------
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.TreeMap;
import java.util.Iterator;

int hexRadius = 32;
int border = hexRadius;

String wordFile = "words.txt";
String lines[];

ColorScheme scheme;

Subsector subs;
Boolean loading = true;

Screen screen;

Ruleset ruleset;

SubsectorDensity density;

TestSuite tests;
int debug = 0;

void setup(){
  // calculated per metrics detailed in SubsectorDisplay, adjust if hexRadius changes
  // panel width = 464, panel height = 646
  size(928, 646);  
  lines = loadStrings(wordFile);
  scheme = new ColorScheme(loadJSONObject(".\\data\\DefaultColors.json"));
  ruleset = new Ruleset();
  density = new SubsectorDensity();
  tests = new TestSuite();  
  screen = new Menu();
}

void draw(){
  screen.drawScreen();
}

void mouseClicked(){
  screen.mouseClicked();
}