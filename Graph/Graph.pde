// playing around with graph structures
// have some thoughts about applicability to the "tesselation of irregular convex polygons" problem
// since the bounding ellipse approach is running into difficulty

boolean debug = false;
Node root;

void setup(){
  size(400, 400);
  root = new Node(width/2, height/2); 
}

void draw(){
  root.show();
}