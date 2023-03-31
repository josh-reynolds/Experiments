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
  
  ColorScheme(JSONObject _json){
    cellBackground  = colorFromJSON(_json.getJSONObject("Hex Background"));
    cellOutline     = colorFromJSON(_json.getJSONObject("Hex Outline"));
    worldName       = colorFromJSON(_json.getJSONObject("World Name"));
    waterPresent    = colorFromJSON(_json.getJSONObject("Water Presence"));
    hexElements     = colorFromJSON(_json.getJSONObject("Hex Elements"));
    systemList      = colorFromJSON(_json.getJSONObject("System List"));
    pageBackground  = colorFromJSON(_json.getJSONObject("Page Background"));
    routes          = colorFromJSON(_json.getJSONObject("Routes"));
    buttonHighlight = colorFromJSON(_json.getJSONObject("Button Highlight"));
    menuBackground  = colorFromJSON(_json.getJSONObject("Menu Background"));
    menuTitle       = colorFromJSON(_json.getJSONObject("Menu Title"));
    menuText        = colorFromJSON(_json.getJSONObject("Menu Text"));
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    json.setJSONObject("Hex Background", colorToJSON(scheme.cellBackground));
    json.setJSONObject("Hex Outline", colorToJSON(scheme.cellOutline));
    json.setJSONObject("World Name", colorToJSON(scheme.worldName));
    json.setJSONObject("Water Presence", colorToJSON(scheme.waterPresent));
    json.setJSONObject("Hex Elements", colorToJSON(scheme.hexElements));
    json.setJSONObject("System List", colorToJSON(scheme.systemList));
    json.setJSONObject("Page Background", colorToJSON(scheme.pageBackground));
    json.setJSONObject("Routes", colorToJSON(scheme.routes));
    json.setJSONObject("Button Highlight", colorToJSON(scheme.buttonHighlight));
    json.setJSONObject("Menu Background", colorToJSON(scheme.menuBackground));
    json.setJSONObject("Menu Title", colorToJSON(scheme.menuTitle));
    json.setJSONObject("Menu Text", colorToJSON(scheme.menuText));
    return json;
  }
  
  color colorFromJSON(JSONObject _json){
    int a = _json.getInt("Alpha");
    int r = _json.getInt("Red");
    int g = _json.getInt("Green");
    int b = _json.getInt("Blue");
    return color(r, g, b, a);
  }
  
  JSONObject colorToJSON(color _c){
    JSONObject json = new JSONObject();
    json.setInt("Alpha", (_c >> 24) & 0xFF);
    json.setInt("Red", (_c >> 16) & 0xFF);
    json.setInt("Green", (_c >> 8) & 0xFF);
    json.setInt("Blue", _c & 0xFF);
    return json;
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