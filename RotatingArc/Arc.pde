class Arc{
  int barWidth;
  float speed;
  float theta;
  float phi;
  color c;
  
  float innerRadius, outerRadius;
  
  Arc(int _width, float _speed, float _startAngle, float _endAngle, color _color){
    barWidth = _width;
    speed = _speed;
    theta = _startAngle;
    phi = _endAngle;
    c = _color;
    
    innerRadius = radius - barWidth/2;
    outerRadius = radius + barWidth/2;
  }
  
  void update(){
    theta += speed;
    phi += speed;
  }
  
  void show(){
    stroke(255);
    strokeWeight(1);
    noFill();

    PVector innerLeft, outerLeft, innerRight, outerRight;
  
    innerLeft  = new PVector(innerRadius * cos(theta), innerRadius * sin(theta));
    outerLeft  = new PVector(outerRadius * cos(theta), outerRadius * sin(theta));
    
    innerRight = new PVector(innerRadius * cos(phi), innerRadius * sin(phi));
    outerRight = new PVector(outerRadius * cos(phi), outerRadius * sin(phi));

    //line(innerLeft.x, innerLeft.y, outerLeft.x, outerLeft.y);
    //line(innerRight.x, innerRight.y, outerRight.x, outerRight.y);
    //arc(0, 0, 2 * innerRadius, 2 * innerRadius, theta, phi, OPEN);
    //arc(0, 0, 2 * outerRadius, 2 * outerRadius, theta, phi, OPEN);
    
    PVector innerMid1, innerMid2, innerMid3, innerMid4;    // left to right
    PVector outerMid1, outerMid2, outerMid3, outerMid4;    // right to left
    
    float offset = (phi - theta)/5;
    
    innerMid1 = new PVector(innerRadius * cos(theta + offset), innerRadius * sin(theta + offset));
    innerMid2 = new PVector(innerRadius * cos(theta + offset * 2), innerRadius * sin(theta + offset * 2));
    innerMid3 = new PVector(innerRadius * cos(theta + offset * 3), innerRadius * sin(theta + offset * 3));
    innerMid4 = new PVector(innerRadius * cos(theta + offset * 4), innerRadius * sin(theta + offset * 4));

    outerMid1 = new PVector(outerRadius * cos(theta + offset * 4), outerRadius * sin(theta + offset * 4));        
    outerMid2 = new PVector(outerRadius * cos(theta + offset * 3), outerRadius * sin(theta + offset * 3));
    outerMid3 = new PVector(outerRadius * cos(theta + offset * 2), outerRadius * sin(theta + offset * 2));
    outerMid4 = new PVector(outerRadius * cos(theta + offset), outerRadius * sin(theta + offset));
      
    stroke(c);
    fill(c);
    beginShape();
      vertex(innerLeft.x, innerLeft.y);

      curveVertex(innerMid1.x, innerMid1.y);    // not quite as smooth as the arc() function
      curveVertex(innerMid2.x, innerMid2.y);
      curveVertex(innerMid3.x, innerMid3.y);    
      curveVertex(innerMid4.x, innerMid4.y);
      
      vertex(innerRight.x, innerRight.y);
      vertex(outerRight.x, outerRight.y);
      
      curveVertex(outerMid1.x, outerMid1.y);
      curveVertex(outerMid2.x, outerMid2.y);
      curveVertex(outerMid3.x, outerMid3.y);
      curveVertex(outerMid4.x, outerMid4.y);
      
      vertex(outerLeft.x, outerLeft.y);
    endShape();
  }
}