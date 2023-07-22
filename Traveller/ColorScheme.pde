class ColorScheme {
  String name;

  color menuBackground;
  color menuTitle;
  color menuText;
  color menuDescriptions;
  color buttonHighlight;
  
  color cellBackground;
  color cellOutline; 
  color worldName;
  color waterPresent;
  color hexElements;
  color amberZone;
  color redZone;
  color routes;

  color pageBackground;
  color systemList;
  
  ColorScheme(String _name, color _cellB, color _cellOut, color _worldN, color _water, color _hexE, color _list, color _pageB, 
              color _routes, color _button, color _menuB, color _menuTitle, color _menuText, color _amberZone, color _redZone,
              color _menuDescrip){
    name             = _name;

    menuBackground   = _menuB;
    menuTitle        = _menuTitle;
    menuText         = _menuText;
    menuDescriptions = _menuDescrip;    
    buttonHighlight  = _button;
    
    cellBackground   = _cellB;
    cellOutline      = _cellOut;
    worldName        = _worldN;
    waterPresent     = _water;
    hexElements      = _hexE;
    amberZone        = _amberZone;
    redZone          = _redZone;
    routes           = _routes;
    
    pageBackground   = _pageB;
    systemList       = _list;
  }
  
  ColorScheme(JSONObject _json){
    name             = _json.getString("Name");

    menuBackground   = colorFromJSON(_json.getJSONObject("Menu Background"));
    menuTitle        = colorFromJSON(_json.getJSONObject("Menu Title"));
    menuText         = colorFromJSON(_json.getJSONObject("Menu Text"));    
    menuDescriptions = colorFromJSON(_json.getJSONObject("Menu Descriptions"));
    buttonHighlight  = colorFromJSON(_json.getJSONObject("Button Highlight"));
    
    cellBackground   = colorFromJSON(_json.getJSONObject("Hex Background"));
    cellOutline      = colorFromJSON(_json.getJSONObject("Hex Outline"));
    worldName        = colorFromJSON(_json.getJSONObject("World Name"));
    waterPresent     = colorFromJSON(_json.getJSONObject("Water Presence"));
    hexElements      = colorFromJSON(_json.getJSONObject("Hex Elements"));
    amberZone        = colorFromJSON(_json.getJSONObject("Amber Zone"));
    redZone          = colorFromJSON(_json.getJSONObject("Red Zone"));
    routes           = colorFromJSON(_json.getJSONObject("Routes"));

    pageBackground   = colorFromJSON(_json.getJSONObject("Page Background"));
    systemList       = colorFromJSON(_json.getJSONObject("System List"));
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    json.setString("Name", name);
    
    json.setJSONObject("Menu Background", colorToJSON(scheme.menuBackground));
    json.setJSONObject("Menu Title", colorToJSON(scheme.menuTitle));
    json.setJSONObject("Menu Text", colorToJSON(scheme.menuText));    
    json.setJSONObject("Menu Descriptions", colorToJSON(scheme.menuDescriptions));    
    json.setJSONObject("Button Highlight", colorToJSON(scheme.buttonHighlight));    
    
    json.setJSONObject("Hex Background", colorToJSON(scheme.cellBackground));
    json.setJSONObject("Hex Outline", colorToJSON(scheme.cellOutline));
    json.setJSONObject("World Name", colorToJSON(scheme.worldName));
    json.setJSONObject("Water Presence", colorToJSON(scheme.waterPresent));
    json.setJSONObject("Hex Elements", colorToJSON(scheme.hexElements));
    json.setJSONObject("Amber Zone", colorToJSON(scheme.amberZone));
    json.setJSONObject("Red Zone", colorToJSON(scheme.redZone));
    json.setJSONObject("Routes", colorToJSON(scheme.routes));    

    json.setJSONObject("Page Background", colorToJSON(scheme.pageBackground));
    json.setJSONObject("System List", colorToJSON(scheme.systemList));

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