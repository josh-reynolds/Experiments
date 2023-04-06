class TextPanel {
  PGraphics pg;
  PFont font;
  int textPanelLeft;
  int textLine;
    
  TextPanel(PGraphics _pg){
    pg = _pg;
    font = loadFont("Consolas-12.vlw");
    textPanelLeft = width/2 + border;
    textLine = border;
  }
  
  void show(Subsector _sub){
    pg.textAlign(LEFT, TOP);
    pg.fill(scheme.systemList);
    
    pg.textFont(font, 24);
    pg.text(_sub.name, textPanelLeft, textLine - 24);
    
    for (System s : _sub.systems.values()){
      if (s.occupied){
        pg.textFont(font, 12);    
        pg.text(s.toString(), textPanelLeft, textLine);    
        textLine += 14;
      }
    }
  }
}