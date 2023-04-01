// Hex geometry and layout
// 
// hex x,y is center
// hexRadius is distance from center to each vertex
//   it is also the length of each side
// yOffset is distance from center to edge (via Pythagoras) 

// hex height                        = 2 x yOffset
// vertical offset (same column)     = hex height
// vertical offset (adjacent column) = hex height / 2 = yOffset
// horizontal offset                 = hexRadius * 1.5 (equilateral triangles)

// TOTAL WIDTH  = (2 x border) + (2 x hexRadius) + ((horzCount - 1) x hexRadius x 1.5)
// TOTAL HEIGHT = (2 x border) + (((2 x vertCount) + 1) x yOffset

//println((2 * border) + (2 * hexRadius) + ((horzCount - 1) * hexRadius * 1.5));
//println((2 * border) + (((2 * vertCount) + 1) * yOffset));
// ------------------------------------------------

class SubsectorDisplay {
  PGraphics screen;
  
  SubsectorDisplay(){
    screen = createGraphics(width, height);
  }
  
  void show(Subsector _sub){
    screen.beginDraw();
    screen.background(scheme.pageBackground);
    
    screen.fill(scheme.cellOutline);
    screen.rect(0, 0, width/2, height);
    
    // may want a separate Text Panel class later
    int textPanelLeft = width/2 + border;
    int textLine = border;
    PFont font = loadFont("Consolas-12.vlw");
    
    for (System s : _sub.systems.values()){
      s.showBackground(screen);
    }
  
    for (Route r : _sub.routes){
      r.show(screen);
    }
    
    screen.textAlign(LEFT, TOP);
    screen.fill(scheme.systemList);
    screen.textFont(font, 24);
    screen.text(_sub.name, textPanelLeft, textLine - 24);
    
    for (System s : _sub.systems.values()){
      s.showForeground(screen);
      
      if (s.occupied){      
        screen.textAlign(LEFT, TOP);
        screen.fill(scheme.systemList);
        screen.textFont(font, 12);    
        screen.text(s.toString(), textPanelLeft, textLine);    
        textLine += 14;
      }
    }
    
    for (System s : _sub.systems.values()){
      if (s.occupied){ s.showName(screen); }
    }
    
    screen.endDraw();
    image(screen, 0, 0);
  }
}