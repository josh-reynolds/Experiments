class Coordinate {
  int column, row;
  
  Coordinate(int _column, int _row){
    column = _column;
    row = _row;
  }
  
  String toString(){
    return nf(column, 2) + nf(row, 2);
  }
}