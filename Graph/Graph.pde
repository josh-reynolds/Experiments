// playing around with graph structures
// have some thoughts about applicability to the "tesselation of irregular convex polygons" problem
// since the bounding ellipse approach is running into difficulty

boolean debug = true;
Node root;

void setup(){
  size(400, 400);
  root = new Node(width/2, height/2);

  Node child = root.neighbors.get(0);
  child.col = color(100, 100, 255);
}

void draw(){
  root.show();
}