// How to Host a Dungeon
//   based on the pen & paper game by Tony Dowler

// mucho refactoring needed - probably going to need classes for all these
// things once they start interacting

// possible alternate approach: use pixel colors like a CA

// reaching the limits of what "just drawing stuff" can do
// planning for the future:
//   * will have fixed spaces/locations as well as mobile entities (creatures + treasures)
//   * creatures will need to navigate the spaces
//   * will need to be able to search all items on the map to find specific types
//   * volcano highlighted need to have surface entities that are drawn in front of the sky -
//       right now just doing a very simple coverup with a sky block to clip underground stuff
//   * eventually creatures will interact with other entities
//   * need to keep a historical record of everything that's happened
//   * at some point we'll want to be able to interact with the map (or at least have labels)
//   * (and of course graphical improvements, but that can always come later)

// Remember YAGNI, and hopefully some refactoring will lead in the right direction
//  but I suspect we're going to have at least a couple classes (locations + entities)
//  and possibly hierarchies to allow polymorphism... but don't get ahead of things

// other possible classes: age/event generators, map object, historic record/log

// thinking about using a simple mask image to govern navigation:
//   all landscape entities draw to both display image and mask (in b+w)
//   all mobile entities use the mask data to assess legal moves
// may eventually need something like A*Star to allow entities to find paths, but keep simple for now

// possibly a third layer for mobile entities so they are always drawn in front

// =============================================
// TO_DO
//  [FIXED] BUG - sky not overdrawing locations that go above ground level
//  [FIXED] don't like locations spawning too close to edge - bring them in a bit
//
// =============================================
float groundLevel = 200;
float thumb = 50;
float bead = 30;
float finger = 300;
float halfFinger = finger/2;
float margin = thumb;

float layerSize;

boolean hasOre = false;   // very simplistic/hacky - sure we'll need a list of 
// locations to query eventually

ArrayList<Location> locations; 

void setup() {
  size(1100, 850);

  background(61, 174, 197);

  layerSize = (height - groundLevel) / 6;

  // draw ground strata
  for (int i = 0; i < 6; i++) {
    float top = groundLevel + (i * layerSize); 

    fill(145, 103, 12);
    rect(0, top, width, layerSize);

    String label = str(i + 1);
    fill(80);
    textSize(48);
    textAlign(LEFT, TOP);
    text(label, 10, top + 20);
  }

  locations = new ArrayList<Location>();

  // PRIMORDIAL AGE ======================================
  new PrimordialAge().generate();

  civilization();

  // draw the sky
  fill(61, 174, 197);
  noStroke();
  rectMode(CORNER);
  rect(0, 0, width, groundLevel);

  printArray(locations);
}

float strataToYCoordinate(int _i) {
  return _i * layerSize + groundLevel + layerSize/2;
}

PVector pickLocation() {
  return new PVector(random(margin, width - margin), random(groundLevel + margin, height - margin));
}

void civilization() {
  // start with the dwarves (blue, square rooms, straight/orthogonal tunnels)
  color dwarves = color(0, 0, 255);

  // do we have a gold vein or mithril?
  //  if not, create a gold vein
  if (!hasOre) {
    new PrimordialAge().createGoldVein();
  }

  // pick spot on surface above gold vein or mithril
  PVector surfaceLocation = new PVector(0, groundLevel);
  PVector targetLocation = new PVector();
  for (Location l : locations) {
    if (l.label.equals("Gold Vein") || l.label.equals("Mithril")) {
      // this just finds the last one - should randomize
      println("found ore!");
      surfaceLocation.x = l.coord.x;
      targetLocation = l.coord.copy();
    }
  }

  // dig a vertical shaft down to the deposit
  stroke(dwarves);
  strokeWeight(4);
  line(surfaceLocation.x, surfaceLocation.y, targetLocation.x, targetLocation.y);

  // draw a mine where the shaft meets the ore, and put a treasure token in it
  rectMode(CENTER);
  stroke(dwarves);
  fill(dwarves);
  rect(targetLocation.x, targetLocation.y, bead, bead);

  stroke(0);
  strokeWeight(1);
  fill(255, 255, 0);
  ellipse(targetLocation.x, targetLocation.y, bead/2, bead/2);    // treasure

  // draw a barracks on the shaft and place a dwarf population token in it
  float barracksDepth = (targetLocation.y - groundLevel)/2 + groundLevel;
  rectMode(CENTER);
  stroke(dwarves);
  fill(dwarves);
  rect(targetLocation.x, barracksDepth, bead, bead);

  stroke(0);
  strokeWeight(1);
  fill(255, 0, 0);
  ellipse(targetLocation.x, barracksDepth, bead/2, bead/2);    // dwarves

  // name the dwarf tribe

  // start counting years from 0 - seasonal events/activities until no dwarves left 
  // or event ends civilization
}