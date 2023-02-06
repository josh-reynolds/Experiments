// How to Host a Dungeon
//   based on the pen & paper game by Tony Dowler

float groundLevel = 200;
float thumb = 50;
float bead = 30;
float finger = 300;
float halfFinger = finger/2;


void setup(){
  size(1100, 850);

  background(61, 174, 197);
  
  float layerSize = (height - groundLevel) / 6;
  
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
    primordial(event);

    fill(255, 0, 0);
    ellipse(p.x, p.y, 10, 10);
  }



}

void primordial(int _e){
  switch(_e){
    case 1:
      println("Mithral");
      for (int i = 0; i < 2; i++){
        PVector location = pickLocation();
        // draw a halfFinger triangle pointing to nearest corner of the map 
      }
      break;
    case 2:
    case 3:
      println("Natural Caverns");
      
      fill(0);
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
      break;
    case 5:
      println("Cave Complex");
      break;
    case 6:
      println("Underground River");
      break;
    case 7:
      println("Ancient Wyrm");
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