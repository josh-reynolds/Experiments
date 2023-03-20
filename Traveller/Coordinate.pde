class Coordinate {
  int column, row;
  int x, y, z;
    
  Coordinate(int _column, int _row){
    column = _column;
    row = _row;

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
}