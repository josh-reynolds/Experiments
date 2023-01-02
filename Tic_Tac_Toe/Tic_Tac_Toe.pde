

Cell[][] cells;
float h,v;

void setup(){
  size(900,900);
  h = width/3;
  v = height/3;
  
  cells = new Cell[3][3];
  for (int i = 0; i < 3; i++){
    for (int j = 0; j < 3; j++){
      cells[i][j] = new Cell(i,j); 
    }
  }
}

void draw(){
  for (int i = 0; i < 3; i++){
    for (int j = 0; j < 3; j++){
      cells[i][j].show(); 
    }
  } 
  drawGrid();
  if (gamewon()){
    println("You won!!!");
    noLoop();
  }
}

boolean gamewon(){
  int col1 = cells[0][0].value + 
             cells[0][1].value +
             cells[0][2].value;
  if (col1 == 3){ return true; }

  int col2 = cells[1][0].value + 
             cells[1][1].value +
             cells[1][2].value;
  if (col2 == 3){ return true; }
  
  int col3 = cells[2][0].value + 
             cells[2][1].value +
             cells[2][2].value;
  if (col3 == 3){ return true; }
  
  int row1 = cells[0][0].value + 
             cells[1][0].value +
             cells[2][0].value;
  if (row1 == 3){ return true; }

  int row2 = cells[0][1].value + 
             cells[1][1].value +
             cells[2][1].value;
  if (row2 == 3){ return true; }
  
  int row3 = cells[0][2].value + 
             cells[1][2].value +
             cells[2][2].value;
  if (row3 == 3){ return true; }
  
  int diag1 = cells[0][0].value + 
              cells[1][1].value +
              cells[2][2].value;
  if (diag1 == 3){ return true; }
  
  int diag2 = cells[2][0].value + 
              cells[1][1].value +
              cells[0][2].value;
  if (diag2 == 3){ return true; }
  
  return false;
}

void drawGrid(){
  stroke(0);
  strokeWeight(12);
  line(h,   0,   h,     height );
  line(h*2, 0,   h*2,   height );
  line(0,   v,   width, v      );
  line(0,   v*2, width, v*2    );
}

void mouseClicked(){
  int hPos = floor(mouseX / h);
  int vPos = floor(mouseY / v);
  
  Cell c = cells[hPos][vPos]; 
  if (mouseButton == LEFT){
    c.update(1);
  }
  if (mouseButton == RIGHT){
    c.update(-1);
  }
}