class ColorScheme {
  color cellBackground;
  color cellOutline;
  color worldName;
  color waterPresent;
  color hexElements;
  color systemList;
  color pageBackground;
  color routes;
  color buttonHighlight;
  color menuBackground;
  color menuTitle;
  color menuText;
  
  ColorScheme(color _cellB, color _cellOut, color _worldN, color _water, color _hexE, color _list, color _pageB, color _routes,
              color _button, color _menuB, color _menuTitle, color _menuText){
    cellBackground  = _cellB;
    cellOutline     = _cellOut;
    worldName       = _worldN;
    waterPresent    = _water;
    hexElements     = _hexE;
    systemList      = _list;
    pageBackground  = _pageB;
    routes          = _routes;
    buttonHighlight = _button;
    menuBackground  = _menuB;
    menuTitle       = _menuTitle;
    menuText        = _menuText;
  }
  
  // Ah! Gotcha! - due to the way Processing works, we
  // can't declare static factory methods (see 
  // https://stackoverflow.com/questions/65237735/static-methods-can-only-be-declared-in-a-static-or-top-level-type-in-processing
  //public static ColorScheme defaultScheme(){
  //  return new ColorScheme(color(0), 
  //                         color(125), 
  //                         color(255, 255, 153), 
  //                         color(0, 125, 255),
  //                         color(255),
  //                         color(0));
  //}
}