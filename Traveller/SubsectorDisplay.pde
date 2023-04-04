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
  PGraphics compositeImage;
  Boolean redraw;
  
  SubsectorDisplay(){
    compositeImage = createGraphics(width, height);
    redraw = true;
  }
  
  void show(Subsector _sub){
    if (redraw){
      PGraphics backgroundLayer = createGraphics(width, height);
      PGraphics foregroundLayer = createGraphics(width, height);
      PGraphics routeLayer      = createGraphics(width, height);
      PGraphics nameLayer       = createGraphics(width, height);
      
      backgroundLayer.beginDraw();
      foregroundLayer.beginDraw();
      routeLayer.beginDraw();
      nameLayer.beginDraw();

      backgroundLayer.fill(scheme.cellOutline);
      backgroundLayer.rect(0, 0, width/2, height);
      
      // may want a separate Text Panel class later
      int textPanelLeft = width/2 + border;
      int textLine = border;
      PFont font = loadFont("Consolas-12.vlw");
      
      foregroundLayer.textAlign(LEFT, TOP);
      foregroundLayer.fill(scheme.systemList);
      foregroundLayer.textFont(font, 24);
      foregroundLayer.text(_sub.name, textPanelLeft, textLine - 24);
      
      for (System s : _sub.systems.values()){
        s.showBackground(backgroundLayer);        
        s.showForeground(foregroundLayer);
        
        if (s.occupied){      
          foregroundLayer.textAlign(LEFT, TOP);
          foregroundLayer.fill(scheme.systemList);
          foregroundLayer.textFont(font, 12);    
          foregroundLayer.text(s.toString(), textPanelLeft, textLine);    
          textLine += 14;

          s.showName(nameLayer);  
        }
      }
    
      for (Route r : _sub.routes){
        r.show(routeLayer);
      }

      backgroundLayer.endDraw();
      foregroundLayer.endDraw();
      routeLayer.endDraw();
      nameLayer.endDraw();

      compositeImage.beginDraw();
      compositeImage.background(scheme.pageBackground);
      compositeImage.image(backgroundLayer, 0, 0);
      compositeImage.image(routeLayer, 0, 0);
      compositeImage.image(foregroundLayer, 0, 0);
      compositeImage.image(nameLayer, 0, 0);
      compositeImage.endDraw();
      redraw = false;
    }
    image(compositeImage, 0, 0);
  }
}