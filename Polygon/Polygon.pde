 


ArrayList<Hex> grid;

void setup(){
  size(600,600);
  background(255);

  grid = new ArrayList<Hex>();

  int radius = 10;
  int xOffset = radius;
  float yOffset = sqrt((radius * radius) - (radius/2 * radius/2));

  int vertCount = floor(height/(2 * yOffset)) - 1;
  int horzCount = floor(width/(1.5 * radius)) - 1;

  for (int i = 0; i < vertCount; i++){
    for (int j = 0; j < horzCount; j++){
      float columnAdjust;
      if (j % 2 == 0){
        columnAdjust = 0;
      } else {
        columnAdjust = yOffset;
      }
      
      grid.add(new Hex(xOffset + j * (radius * 1.5), 
                       yOffset + (yOffset * i * 2) + columnAdjust, 
                       radius, 
                       color((yOffset + (yOffset * i * 2) + columnAdjust)/height * 255, 
                             (xOffset + j * (radius * 1.5))/width * 255,
                             100)));
    }
  }
  
  for (Hex h : grid){
    h.show();
  }
}