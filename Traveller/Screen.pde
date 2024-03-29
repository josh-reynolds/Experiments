abstract class Screen {
  abstract void drawScreen();
  abstract void mouseClicked();
  abstract void keyPressed();
}

class Menu extends Screen {
  Button[] buttons;
  
  Menu(){
    buttons = new Button[6];
    buttons[0] = new Button("New", 32, border, border * 4, new NewSubsector());
    buttons[1] = new Button("Load", 32, border, border * 6, new Load());
    buttons[2] = new Button("Colors", 32, border, border * 8, new ChangeColors());
    buttons[3] = new Button("Rules", 32, border, border * 10, new ChangeRules());
    buttons[4] = new Button("Density", 32, border, border * 12, new ChangeDensity());
    buttons[5] = new Button("Traffic", 32, border, border * 14, new ChangeTraffic());
  }
  
  void drawScreen(){
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

    String trafficDescription = "Traffic: " + traffic.getLabel();
    float trafficDescriptionWidth = textWidth(trafficDescription);
    text(trafficDescription, width - trafficDescriptionWidth - border, height - (2 * titleSize) - border);
    
    String densityDescription = "Density: " + density.getLabel();
    float densityDescriptionWidth = textWidth(densityDescription);
    text(densityDescription, width - densityDescriptionWidth - border, height - (3 * titleSize/2) - border);
    
    String colorSchemeDescription = "Color scheme: " + scheme.name;
    float colorSchemeDescriptionWidth = textWidth(colorSchemeDescription); 
    text(colorSchemeDescription, width - colorSchemeDescriptionWidth - border, height - titleSize - border);
    
    String rulesDescription = "Rules: " + ruleset.name;
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
  
  void mouseClicked(){
    for (Button b : buttons){
      if (b.highlight){ b.run(); }
    }
  }

  void keyPressed(){}
}

class Display extends Screen {
  SubsectorDisplay subD;
  TextPanel textPanel;
  
  Display(){
    subD = new SubsectorDisplay();
    textPanel = new TextPanel();
  }
  
  void drawScreen(){
    subD.mouseHover(subs);
    subD.show(subs);
    textPanel.show(subs);
    ship.show();
  }
  
  void mouseClicked(){
    for (System s : subs.systems.values()){
      if (s.hex.contains(mouseX, mouseY)){
        if (ruleset.supportsStars()){
          println(s.extendedString());
          println(((System_ScoutsEx)s).list());
        } else {
          println(s.extendedString());
        }
      }
    }
  }

  void keyPressed(){
    screen = new Detail();
  }
}

class Detail extends Screen {
  
  // eventually create panels for this content, just playing with ideas for now...
  
  Detail(){
  }
  
  void drawScreen(){
    background(scheme.menuBackground);
    
    fill(scheme.menuText);
    textSize(14);     
    textAlign(LEFT, TOP);
    text(ship.location.toString(), 10, 10);
    
    
  }
  
  void mouseClicked(){
  }

  void keyPressed(){
    screen = new Display();
  }
}