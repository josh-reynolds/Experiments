class PrimordialAge {

  void generate() {
    for (int i = 0; i < 3; i++) {
      PVector p = pickLocation();
      int index = floor(random(1, 9));
      event(index, p);
      //event(4, p);
    }
  }

  private void event(int _e, PVector _p) {
    switch(_e) {
    case 1:
      createMithril();
      break;
    case 2:
    case 3:
      createNaturalCaverns();
      break;
    case 4:
      createGoldVein();
      break;
    case 5:
      createCaveComplex(_p);
      break;
    case 6:
      createUndergroundRiver();
      break;
    case 7:
      createAncientWyrm(_p);
      break;
    case 8:
      createNaturalDisaster();
      break;
    default:
      println("Invalid die roll - should not get here.");
    }
  }

  private void createMithril() {
    println("Mithril");
    hasOre = true;
    for (int i = 0; i < 2; i++) {
      PVector location = pickLocation();
      locations.add(new Location("Mithril", location));

      // find nearest corner
      float minDist = width;
      int minIndex = 0;
      PVector[] corners = new PVector[4];
      corners[0] = new PVector(0, 0);
      corners[1] = new PVector(width, 0);
      corners[2] = new PVector(0, height);
      corners[3] = new PVector(width, height);

      for (int j = 0; j < 4; j++) {
        float dist = PVector.dist(location, corners[j]); 
        if (dist < minDist) {
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
      for (int k = 0; k < 3; k++) {
        vertex(direction.x + location.x, direction.y + location.y);
        direction.rotate(radians(120));
      }
      endShape(CLOSE);
    }
  }


  private void createNaturalCaverns() {
    println("Natural Caverns");      
    fill(0);
    noStroke();

    int cavernCount = 0;
    int roll = 0;

    // need to add Natural Cavern table results

    while (roll != 6 && cavernCount < 6) {
      roll = createCavern();
      cavernCount++;
    }
  }

  private int createCavern() {
    PVector location = pickLocation();
    locations.add(new Location("Natural Cavern", location));
    ellipse(location.x, location.y, bead, bead);
    return floor(random(1, 7));
  }

  private void createGoldVein() {
    println("Gold Vein");
    hasOre = true;
    int left = floor(random(0, 6));
    int right = floor(random(0, 6));

    PVector start = new PVector(0, strataToYCoordinate(left));
    PVector end = new PVector(width, strataToYCoordinate(right));

    stroke(255, 0, 0);
    strokeWeight(2);
    line(start.x, start.y, end.x, end.y); 

    // need to decide what "location" means for a line like this
    //  for now pick a random point on the line
    PVector direction = PVector.sub(end, start);
    direction.mult(random(0.1, 0.9));
    PVector location = new PVector(direction.x + start.x, direction.y + start.y);
    fill(255, 0, 0);
    ellipse(location.x, location.y, 10, 10);
    locations.add(new Location("Gold Vein", location));
  }

  private void createCaveComplex(PVector _p) {
    println("Cave Complex");
    locations.add(new Location("Cave Complex", _p));
    for (int i = 0; i < 3; i++) {
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
  }

  private void createUndergroundRiver() {
    println("Underground River");
    boolean active = true;
    int start = floor(random(0, 6));
    float currentX = 0;
    float currentY = strataToYCoordinate(start);

    ArrayList<PVector> river = new ArrayList<PVector>();
    river.add(new PVector(currentX, currentY));

    while (active) {
      int choice = floor(random(0, 10));
      switch (choice) {
      case 0:
      case 1:
      case 2:
        currentX += finger;      
        break;
      case 3:
      case 4:
        currentX += finger;
        currentY -= layerSize;
        break;
      case 5:
      case 6:
        currentX += finger;
        currentY += layerSize;
        break;
      case 7:
      case 8:
        currentX += finger;
        // add a cave and/or sinkhole
        break;
      case 9:
        currentY += halfFinger;
        break;
      default:
        println("  Invalid die roll");
      }
      river.add(new PVector(currentX, currentY));
      if (currentX > width || currentY < groundLevel || currentY > height) {
        active = false;
        // add lake/sinkhole as necessary
      }
    }

    stroke(0, 0, 255);
    strokeWeight(3);
    noFill();
    beginShape();
    for (PVector p : river) {
      vertex(p.x, p.y);
    }
    endShape();

    // same issue here as with Gold Vein - what point to choose?
    //      locations.add(new Location("Underground River", location));
  }

  private void createAncientWyrm(PVector _p) {
    println("Ancient Wyrm");
    locations.add(new Location("Ancient Wyrm", _p));
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
  }

  private void createNaturalDisaster() {
    println("Natural Disaster");
    int choice = floor(random(0, 8));
    switch (choice) {
    case 0:
    case 1:
    case 2:
      println("  Earthquake");
      break;
    case 3:
      println("  Volcanic Eruption");
      float x = random(0, width);
      float y = height - random(0, 200);
      fill(255, 0, 0);
      ellipse(x, y, thumb * 2, thumb);
      stroke(255, 0, 0);
      strokeWeight(6);
      line(x, y, x, groundLevel);

      // draw volcano cone - needs to be in foreground

      // even trickier than with rivers & gold veins because
      //  this is a vertical line
      // locations.add(new Location("Volcano", location));

      break;
    case 4:
      println("  The Great River");
      break;
    case 5:
      println("  The Plague");        
      break;
    case 6:
      println("  The Fallen Star");        
      break;
    case 7:
      println("  Make something up");        
      break;
    default:
      println("  Invalid die roll");
    }
  }
}