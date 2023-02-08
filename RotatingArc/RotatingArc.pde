// quick sketch based off a TV screen saver graphic

int radius = 100;
float angularWidth = HALF_PI/3;
float spacing = 0.1;
int arcCount = 5;
int arcWidth = 20;
float arcSpeed = 0.05;

ArrayList<Arc> arcs;

void setup(){
  size(600, 600);

  arcs = new ArrayList<Arc>();
  float startAngle = 0;
  for (int i = 0; i < arcCount; i++){
    arcs.add(new Arc(arcWidth, arcSpeed, startAngle, startAngle + angularWidth));
    startAngle += angularWidth + spacing;
  }
}

void draw(){
  background(51);  
  translate(width/2, height/2);
  
  for (Arc a : arcs){
    a.update();
    a.show();
  }
  
  fill(255);
  arc(0, 0, radius * 2, radius * 2, radians(45), radians(135), PIE);
}