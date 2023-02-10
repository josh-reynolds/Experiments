
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
    //ellipse(points[i].x, points[i].y, sideLength * 2, sideLength * 2);
  }
  
  // BOUNDING ELLIPSE - NEXT POLY ===================
  PVector firstPoint  = points[0];
  PVector secondPoint = points[1];
  
  fill(0, 255, 0);
  ellipse(firstPoint.x, firstPoint.y, 6, 6);
  
  fill(255, 0, 0);
  ellipse(secondPoint.x, secondPoint.y, 6, 6);  
  
  // have x,y for two sample points on the ellipse
  // center point is unknown as is angle to sample points from it 
  // assume x + y radii are same as central ellipse 
  
  // if   x1 = h + (a cos t1) && x2 = h + (a cos t2) 
  // then  h = x1 - (a cos t1) = x2 - (a cos t2)
  //  x1 = x2 - (a cos t2) + (a cos t1)
  //  x1 - x2 = -(a cos t2) + (a cos t1) = (a cos t1) - (a cos t2)
  // (x1 - x2) / a = cos t1 - cos t2
    
  // same for y:
  // y1 = k + (b sin t1) && y2 = k + (b sin t2)
  // k = y1 - (b sin t1) = y2 - (b sin t2)
  // y1 = y2 - (b sin t2) + (b sin t1)
  // y1 - y2 = (b sin t1) - (b sin t2)
  // (y1 - y2) / b = sin t1 - sin t2
  
  float targetX = (firstPoint.x - secondPoint.x) / xRadius;
  float targetY = (firstPoint.y - secondPoint.y) / yRadius;
  
  for (float angle1 = 0; angle1 <= TWO_PI; angle1 += 0.1){
    for (float angle2 = 0; angle2 <= TWO_PI; angle2 += 0.1){
      float xCandidate = (cos(angle1) - cos(angle2));
      float yCandidate = (sin(angle1) - sin(angle2));
      boolean foundX = false;
      boolean foundY = false;
      if (abs(xCandidate - targetX) < 0.001){ 
        println("got one x! " + degrees(angle1) + " " + degrees(angle2)); 
        foundX = true;
      }
      if (abs(yCandidate - targetY) < 0.001){ 
        println("got one y! " + degrees(angle1) + " " + degrees(angle2)); 
        foundY = true; 
      }
      if (foundX && foundY){ 
        println("Found it!");
        // this approach is not finding an intersecting ellipse
        // so assumptions are probably wrong
        // either new ellipse does not have same radii and/or
        // it is rotated w.r.t. x & y axes
      }
    }
  }
  
  println("DONE");
}