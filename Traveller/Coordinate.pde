class Coordinate {
  int column, row;
  int x, y, z;

  float yOffset = sqrt((hexRadius * hexRadius) - (hexRadius/2 * hexRadius/2));
  int startX = hexRadius + border;    
  int startY = (int)yOffset + border;
  
  Coordinate(int _column, int _row){
    column = _column;
    row = _row;
    calculateThreeCoord();
  }
  
  Coordinate(JSONObject _json){
    column = _json.getInt("Column");
    row = _json.getInt("Row");
    calculateThreeCoord();  
  }
  
  void calculateThreeCoord(){
    x = column - 1;
    z = (row - 1) - floor((column - 1)/2);
    y = -x - z;
  }
  
  String toString(){
    return nf(column, 2) + nf(row, 2);
  }
  
  int distanceTo(Coordinate _c){
    return max(abs(x - _c.x), abs(y - _c.y), abs(z - _c.z));
  }
  
  // loop & geometry are 0-based, but coordinates are 1-based
  // so have adjustments in these functions to reconcile

  float getScreenX(){
    return startX + (column - 1) * (hexRadius * 1.5);
  }
  
  float getScreenY(){
    float columnAdjust;
    if ((column - 1) % 2 == 0){
      columnAdjust = 0;
    } else {
      columnAdjust = yOffset;
    }
    
    return startY + (yOffset * (row - 1) * 2) + columnAdjust;
  }
  
  JSONObject asJSON(){
    JSONObject json = new JSONObject();
    json.setInt("Column", column);
    json.setInt("Row", row);
    return json;
  }
  
  Boolean equals(Coordinate _c){
    return column == _c.column && row == _c.row;
  }
}