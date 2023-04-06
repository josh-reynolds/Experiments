class TextPanel {
  PGraphics image;
  Boolean redraw = true;
  
  PFont font;
  int textPanelLeft;
  int textLine;
    
  TextPanel(){
    image = createGraphics(width/2, height);
    font = loadFont("Consolas-12.vlw");
    textPanelLeft = border;
    textLine = border;
  }
  
  void show(Subsector _sub){
    if (redraw){
      image.beginDraw();
        image.background(scheme.pageBackground);
        image.fill(scheme.systemList);
        image.textAlign(LEFT, TOP);
        
        image.textFont(font, 24);
        image.text(_sub.name, textPanelLeft, textLine - 24);
        
        for (System s : _sub.systems.values()){
          if (s.occupied){
            image.textFont(font, 12);    
            image.text(s.toString(), textPanelLeft, textLine);    
            textLine += 14;
          }
        }
      image.endDraw();
      redraw = false;
    }
    image(image, width/2, 0);
  }
}