
// Drawing arbitrary irregular convex polygons
//   select points from a bounding ellipse to ensure convexivity

// parametric ellipse  (https://mathopenref.com/coordparamellipse.html)
//  x = h + (a cos t)
//  y = k + (b sin t)

PVector center = new PVector(200, 200);
int xRadius = 120;
int yRadius = 60;

void setup(){
  size(400, 400); 
  noFill();
  
  //// CENTER POINT =================================
  //ellipse(center.x, center.y, 8, 8);

  //// BOUNDING ELLIPSE =============================
  //beginShape();
  //  for (float angle = 0; angle <= TWO_PI; angle += 0.1){
  //    float x = center.x + (xRadius * cos(angle));
  //    float y = center.y + (yRadius * sin(angle));
  //    vertex(x, y);
  //  }
  //endShape(CLOSE);

  int sides = floor(random(6, 8));
  PVector[] points = new PVector[sides];

  // POLYGON ========================================
  stroke(255,0,0);
  strokeWeight(2);
  beginShape();
    float angleDelta = TWO_PI / sides;
    float theta = random(0, TWO_PI);
    for (int i = 0; i < sides; i++){
      float x = center.x + (xRadius * cos(theta));
      float y = center.y + (yRadius * sin(theta));
      vertex(x, y);
      theta += angleDelta;
      points[i] = new PVector(x, y);
    }
  endShape(CLOSE);
  
  // SIDE LENGTHS ===================================
  float sumLength = 0;
  float minLength = width;
  float maxLength = 0;
  for (int i = 0; i < sides; i++){
    float d;
    if (i + 1 < sides){
      d = PVector.dist(points[i], points[i+1]);
    } else {
      d = PVector.dist(points[i], points[0]);
    }
    sumLength += d;
    if (d < minLength){ minLength = d; }
    if (d > maxLength){ maxLength = d; }
    //println(d);
  }
  println("Sides = " + sides);
  println("Average side length = " + sumLength / sides);
  println("Max length = " + maxLength);
  println("Min length = " + minLength);

  //float sideLength = PVector.dist(points[0], points[1]);
  float sideLength = sumLength / sides;
    
  // SPINES =========================================
  stroke(0, 0, 255);
  strokeWeight(1);
  for (int i = 0; i < sides; i++){
    PVector direction = PVector.sub(points[i], center);
    direction.setMag(sideLength);
    PVector endPoint = PVector.add(points[i], direction);
    line(points[i].x, points[i].y, endPoint.x, endPoint.y);
    ellipse(points[i].x, points[i].y, sideLength * 2, sideLength * 2);
  }
  
  fill(0, 255, 0);
  ellipse(points[0].x, points[0].y, 6, 6);
  
  fill(255, 0, 0);
  ellipse(points[1].x, points[1].y, 6, 6);
}