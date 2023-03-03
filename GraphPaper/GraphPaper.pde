


int cellSize = 20;
float theta = PI/3;

void setup(){
  size(400, 400);
}

void draw(){
  drawGrid();
  println("\nIdentity matrix");
  printMatrix();
  
  translate(width/2, height/2);
  println("Translation matrix");
  printMatrix();
  
  drawDot(0, 0);
  drawDot(5, 4);
  
  rotate(theta);
  println("Rotation + translation matrix");
  printMatrix();
  println("sin(theta) = " + sin(theta));
  println("cos(theta) = " + cos(theta));

  drawDot(5, 4);
}

void drawGrid(){
  background(255);
  stroke(0, 125, 255);
  strokeWeight(1);
  
  // draw horizontal lines
  for (int i = cellSize; i < height; i += cellSize){
    line(0, i, width, i);
  }
  
  // draw vertical lines
  for (int i = cellSize; i < width; i += cellSize){
    line(i, 0, i, height);
  }
  
  // draw axes thicker
  strokeWeight(2);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
}

void drawDot(int _x, int _y){
  int xCoord = _x * cellSize;
  int yCoord = -(_y * cellSize);
  
  fill(255, 125, 0);
  stroke(0);
  ellipse(xCoord, yCoord, 10, 10);
  
  fill(0);
  text(_x + ", " + _y, xCoord + 6, yCoord - 6); 
}