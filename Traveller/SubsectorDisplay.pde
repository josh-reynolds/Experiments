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
  TextPanel textPanel;
  PGraphics foregroundLayer; // temporarily moving up during refactor of text panel code
  
  SubsectorDisplay(){
    compositeImage = createGraphics(width, height);
    foregroundLayer = createGraphics(width, height);
    textPanel = new TextPanel(foregroundLayer);
    redraw = true;
  }
  
  void show(Subsector _sub){
    if (redraw){
      PGraphics backgroundLayer = createGraphics(width, height);
      //PGraphics foregroundLayer = createGraphics(width, height);
      PGraphics routeLayer      = createGraphics(width, height);
      PGraphics nameLayer       = createGraphics(width, height);
      
      backgroundLayer.beginDraw();
      foregroundLayer.beginDraw();
      routeLayer.beginDraw();
      nameLayer.beginDraw();

      backgroundLayer.fill(scheme.cellOutline);
      backgroundLayer.rect(0, 0, width/2, height);
      
      textPanel.show(_sub);
      
      for (System s : _sub.systems.values()){        
        showBackground(backgroundLayer, s);
        showForeground(foregroundLayer, s);
        
        if (s.occupied){
          showName(nameLayer, s);
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

  void showBackground(PGraphics _pg, System _s){
    _s.hex.drawHex(_pg);
    
    _pg.fill(scheme.cellOutline);
    _pg.textSize(9);
    _pg.textAlign(CENTER, TOP);
    _pg.text(_s.coord.toString(), _s.hex.x, _s.hex.y + hexRadius/2);
  }
  
  void showForeground(PGraphics _pg, System _s){
    if (_s.occupied){
      _pg.strokeWeight(1);
      _pg.stroke(scheme.hexElements);           
      _pg.fill(scheme.hexElements);

      if (_s.navalBase){ _s.hex.drawStar(_pg); }
      if (_s.scoutBase){ _s.hex.drawTriangle(_pg); }
      if (_s.gasGiant ){ _pg.ellipse(_s.hex.x + hexRadius/3, _s.hex.y - hexRadius/3, hexRadius/6, hexRadius/6); }
      
      _pg.textSize(12);
      _pg.textAlign(CENTER, CENTER);
      _pg.text(_s.uwp.starport, _s.hex.x, _s.hex.y - hexRadius/2);

      if (_s.uwp.hydro == 0){ 
        _pg.fill(scheme.cellBackground);
      } else {
        _pg.fill(scheme.waterPresent);
      }

      _pg.ellipse(_s.hex.x, _s.hex.y, 5 * hexRadius/12, 5 * hexRadius/12);  
    }
  }
  
  void showName(PGraphics _pg, System _s){
    _pg.fill(scheme.worldName);
    _pg.textSize(11);
    _pg.textAlign(CENTER, CENTER);
    if (_s.uwp.pop >= 9){
      _pg.text(_s.name.toUpperCase(), _s.hex.x, _s.hex.y + hexRadius/2);
    } else {
      _pg.text(_s.name, _s.hex.x, _s.hex.y + hexRadius/2);
    }
  }
}