// constrain a random walker with a navigation mask

Walker w;
PGraphics mask;

void setup(){
  size(400, 400);

  mask = createGraphics(width, height);
  mask.beginDraw();
    mask.background(0);
    mask.rect(100, 100, 200, 200);
  mask.endDraw();

  background(mask);

  w = new Walker(width/2, height/2);
}

void draw(){
  w.update();
  w.show();
}