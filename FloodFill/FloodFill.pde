// Trying out a flood-fill algorithm using BFS


ArrayList<PVector> queue;
PVector start;

color oldC = color(255, 0, 0);
color newC = color(0, 0, 255);

int iterations = 10000;

void setup(){
  size(400, 400);
  
  queue = new ArrayList<PVector>();
  start = new PVector(width/2, height/2);
  queue.add(start);
  
  background(255);
  noStroke();
  fill(oldC);
  rect(100, 100, 200, 200);
  
  //background(oldC);
}

void draw(){
  floodFill();
  println(frameCount + " : " + queue.size());
}

void floodFill(){
  for (int i = 0; i < iterations; i++){
    if (queue.size() > 0){
      PVector candidate = queue.remove(0);
      if (getAt(candidate) == oldC &&
          candidate.x >= 0 &&
          candidate.x < width &&
          candidate.y >= 0 &&
          candidate.y < height){
        
        setAt(candidate, newC);
        
        queue.add(new PVector(candidate.x - 1, candidate.y));
        queue.add(new PVector(candidate.x, candidate.y - 1));
        queue.add(new PVector(candidate.x + 1, candidate.y));
        queue.add(new PVector(candidate.x, candidate.y + 1));
      }
    }
  }
}

color getAt(PVector _p){
  return get(floor(_p.x), floor(_p.y));
}

void setAt(PVector _p, color _c){
  set(floor(_p.x), floor(_p.y), _c);
}