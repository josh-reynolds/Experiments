class Arc{
  int barWidth;
  float speed;
  float theta;
  float phi;
  
  float innerRadius, outerRadius;
  PVector innerLeft, outerLeft, innerRight, outerRight;
  
  Arc(int _width, float _speed, float _startAngle, float _endAngle){
    barWidth = _width;
    speed = _speed;
    theta = _startAngle;
    phi = _endAngle;
  
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

    innerLeft  = new PVector(innerRadius * cos(theta), innerRadius * sin(theta));
    outerLeft  = new PVector(outerRadius * cos(theta), outerRadius * sin(theta));
    line(innerLeft.x, innerLeft.y, outerLeft.x, outerLeft.y);
    
    innerRight = new PVector(innerRadius * cos(phi), innerRadius * sin(phi));
    outerRight = new PVector(outerRadius * cos(phi), outerRadius * sin(phi));
    line(innerRight.x, innerRight.y, outerRight.x, outerRight.y);
    
    arc(0, 0, 2 * innerRadius, 2 * innerRadius, theta, phi, OPEN);
    arc(0, 0, 2 * outerRadius, 2 * outerRadius, theta, phi, OPEN);
  }
}