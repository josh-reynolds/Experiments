class Coordinate {
  int column, row;
  int x, y, z;
    
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