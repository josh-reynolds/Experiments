// How to Host a Dungeon
//   based on the pen & paper game by Tony Dowler

// mucho refactoring needed - probably going to need classes for all these
// things once they start interacting

// possible alternate approach: use pixel colors like a CA

float groundLevel = 200;
float thumb = 50;
float bead = 30;
float finger = 300;
float halfFinger = finger/2;

float layerSize;

void setup(){
  size(1100, 850);

  background(61, 174, 197);
  
  layerSize = (height - groundLevel) / 6;
  
  for (int i = 0; i < 6; i++){
    float top = groundLevel + (i * layerSize); 
    
    fill(145, 103, 12);
    rect(0, top, width, layerSize);
    
    String label = str(i + 1);
    fill(80);
    textSize(48);
    textAlign(LEFT, TOP);
    text(label, 10, top + 10); 
  }
  
  // PRIMORDIAL AGE ======================================
  for (int i = 0; i < 3; i++){
    PVector p = pickLocation();
    int event = floor(random(1, 9));
    primordial(event, p);
    
    //primordial(1, p);
  }

  fill(61, 174, 197);
  noStroke();
  rect(0, 0, width, groundLevel);
}

void primordial(int _e, PVector _p){
  switch(_e){
    case 1:
      println("Mithral");
      for (int i = 0; i < 2; i++){
        PVector location = pickLocation();
        
        // find nearest corner
        float minDist = width;
        int minIndex = 0;
        PVector[] corners = new PVector[4];
        corners[0] = new PVector(0, 0);
        corners[1] = new PVector(width, 0);
        corners[2] = new PVector(0, height);
        corners[3] = new PVector(width, height);
        
        for (int j = 0; j < 4; j++){
          float dist = PVector.dist(location, corners[j]); 
          if (dist < minDist){
            minDist = dist;
            minIndex = j;
          }
        }
        
        // draw a half-finger triangle pointing to it 
        PVector direction = PVector.sub(corners[minIndex], location);
        float l = (halfFinger * sin(radians(60))) / 2;
        direction.setMag(l);
        
        stroke(0);
        fill(100);
        beginShape();
          for (int k = 0; k < 3; k++){
            vertex(direction.x + location.x, direction.y + location.y);
            direction.rotate(radians(120));
          }
        endShape(CLOSE);
      }
      break;
    case 2:
    case 3:
      println("Natural Caverns");      
      fill(0);
      noStroke();
      PVector location = pickLocation();
      ellipse(location.x, location.y, bead, bead);

      int cavernCount = 1;
      int roll = floor(random(1, 7));
      while (roll != 6 && cavernCount < 6){
        location = pickLocation();
        ellipse(location.x, location.y, bead, bead);
        roll = floor(random(1, 7));
        cavernCount++;
      }
      break;
    case 4:
      println("Gold Vein");
      int left = floor(random(0, 6));
      int right = floor(random(0, 6));
      
      stroke(255, 0, 0);
      strokeWeight(2);
      line(0,     left * layerSize + groundLevel + layerSize/2,
           width, right * layerSize + groundLevel + layerSize/2);
      
      break;
    case 5:
      println("Cave Complex");
      for (int i = 0; i < 3; i++){
        PVector displacement = PVector.random2D();
        displacement.setMag(bead);
        PVector l = PVector.add(_p, displacement);
              
        fill(0);
        noStroke();
        ellipse(l.x, l.y, bead, bead);

        stroke(0);
        strokeWeight(2);
        line(_p.x, _p.y, l.x, l.y);

        fill(255, 0, 0);
        ellipse(l.x, l.y, bead/2, bead/2);    // primordial beasts
      }
      break;
    case 6:
      println("Underground River");

      break;
    case 7:
      println("Ancient Wyrm");
      fill(0);
      noStroke();
      ellipse(_p.x, _p.y, bead, bead);
      PVector displacement = PVector.random2D();
      displacement.setMag(bead/2);
      PVector newLocation = PVector.add(_p, displacement);
      ellipse(newLocation.x, newLocation.y, bead, bead);
      
      fill(255, 0, 0);
      ellipse(_p.x, _p.y, bead/2, bead/2);    // ancient wyrm
      
      fill(255, 255, 0);
      ellipse(newLocation.x, newLocation.y, bead/2, bead/2);    // treasure
      break;
    case 8:
      println("Natural Disaster");
      break;
    default:
      println("Invalid die roll - should not get here.");
  }
  
}

PVector pickLocation(){
  return new PVector(random(width), random(groundLevel, height));
}