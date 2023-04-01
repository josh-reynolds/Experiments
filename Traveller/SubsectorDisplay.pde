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
  
  SubsectorDisplay(){}
  
  void show(Subsector _sub){
    background(scheme.pageBackground);
    
    fill(scheme.cellOutline);
    rect(0, 0, width/2, height);
    
    // may want a separate Text Panel class later
    int textPanelLeft = width/2 + border;
    int textLine = border;
    PFont font = loadFont("Consolas-12.vlw");
    
    for (System s : _sub.systems.values()){
      s.showBackground();
    }
  
    for (Route r : _sub.routes){
      r.show();
    }
    
    textAlign(LEFT, TOP);
    fill(scheme.systemList);
    textFont(font, 24);
    text(_sub.name, textPanelLeft, textLine - 24);
    
    for (System s : _sub.systems.values()){
      s.showForeground();
      
      if (s.occupied){      
        textAlign(LEFT, TOP);
        fill(scheme.systemList);
        textFont(font, 12);    
        text(s.toString(), textPanelLeft, textLine);    
        textLine += 14;
      }
    }
    
    for (System s : _sub.systems.values()){
      if (s.occupied){ s.showName(); }
    }
  }
}