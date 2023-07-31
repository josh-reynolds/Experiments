class Button{
  String label;
  int size, left, top;
  float buttonWidth;
  Boolean highlight = false;
  Command command;
  
  Button(String _label, int _size, int _left, int _top, Command _command){
    label = _label;
    size = _size;
    left = _left;
    top = _top;
    
    command = _command;
    command.register(this);
    
    textSize(size);
    buttonWidth = textWidth(label);
  }
  
  void run(){
    command.run();
  }
  
  void show(){
    textSize(size);
    textAlign(LEFT, TOP);
    
    fill(scheme.menuBackground);
    noStroke();
    rect(left, top, buttonWidth, size);
    
    if (highlight){
      fill(scheme.buttonHighlight);
    } else {
      fill(scheme.menuText);
    }
    text(label, left, top);
  }
  
  void mouseHover(){
    if (mouseX > left && mouseX < left + buttonWidth &&
        mouseY > top  && mouseY < top + size){
      highlight = true;          
    } else {
      highlight = false;
    }
  }
}

interface Command {
  void register(Button _b);
  void run();
}

class NewSubsector extends ButtonUtilities implements Command {
  Button b;    // timing issue, button doesn't exist when we construct the command
               // was initially thinking of having this passed in during ctor
               // slightly hacky approach for now - button ctor should register itself with the
               // command - we can make that explicit with a register method
  
  NewSubsector(){}
  
  void register(Button _b){ b = _b; }
  
  void run(){
    println(b.label);
    b.highlight = false;
    loading = false;
    subs = createSubsector();
    screen = new Display();
    screen.drawScreen();
    writeImage();
    writeText();
    writeJSON();
    tests.run();
    
    println(ship);
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
    
    if (ruleset.supportsStars()){
      for (System s : subs.systems.values()){ 
        if (s.occupied){
          output.println(((System_ScoutsEx)s).list());
          output.println("=========================");
        }
      }
    }
    
    output.flush();
    output.close();
    
    println(subs.summary);
  }
  
  void writeJSON(){
    String jsonFileName = ".\\output\\" + subs.name + ".json";
    saveJSONObject(subs.asJSON(), jsonFileName);
  }
}

public class Load extends ButtonUtilities implements Command {
  Button b;
  
  Load(){}
  
  void register(Button _b){ b = _b; }

  void run(){
    println(b.label);
    selectInput("Select a subsector json file to load.", "subsectorFileSelected", dataFile(".\\output\\*.json"), this);
    // this filters, though the dialog "Files of Type" box doesn't reflect that fact
    // and if you type "*.txt" in the selection box, for instance, it will change the hidden filter in use
    // see https://discourse.processing.org/t/selectinput-i-like-to-tell-it-the-folder-to-use/13703/10
    
    // also, more shenanigans due to the Processing inner-class model
    // selectInput documentation is very sparse, but once this code moved over here from the parent script
    // it couldn't find the callback method. Needed two changes:
    //  - add the final argument as a reference back to the Command object (or get "could not find subsectorFileSelected()")
    //  - make the Command subclass public (or get "subsectorFileSelected() must be public")
    // see https://forum.processing.org/two/discussion/2444/selectinput-in-a-class-in-eclipse-callback-not-found.html
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
  
    b.highlight = false;
    screen = new Display();
  }
}

public class ChangeColors extends ButtonUtilities implements Command {
  Button b;
  
  ChangeColors(){}
  
  void register(Button _b){ b = _b; }
  
  void run(){
    println(b.label);
    selectInput("Select a color json file to load.", "colorFileSelected", dataFile(".\\data\\*.json"), this);
  }

  void colorFileSelected(File _selection){
    if (nullSelection(_selection)){ return; }
    if (notJSONFile(_selection)){ return; }
    println(_selection);
    
    scheme = new ColorScheme(loadJSONObject(_selection.toString()));
  
    b.highlight = false;
    screen = new Menu();
  }
}

class ChangeRules implements Command {
  Button b;
  
  ChangeRules(){}
  
  void register(Button _b){ b = _b; }
  
  void run(){
    println(b.label);
    ruleset.next();
    if (!ruleset.supportsDensity()){
      density = new SubsectorDensity();
    }
  }
}

class ChangeDensity implements Command {
  Button b;
  
  ChangeDensity(){}
  
  void register(Button _b){ b = _b; }
  
  void run(){
    println(b.label);
    if (ruleset.supportsDensity()){
      density.next();
    } else {
      println("This ruleset doesn't support system density. Defaulting to Standard.");
    }
  }
}

// kind of a grab-bag for now - further refactoring can tease this apart
// this allows Command classes access to formerly-public methods pushed
// down from the parent script, without duplicating into each subclass
class ButtonUtilities {
  String jsonFile = "";
  
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
  
  Subsector createSubsector(){
    if (loading){
      JSONObject subsectorData = loadJSONObject(jsonFile);
      return new Subsector(subsectorData);
    } else {
      return new Subsector();
    }
  }
}