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

// other possible classes: age/event generators, map object

// thinking about using a simple mask image to govern navigation:
//   all landscape entities draw to both display image and mask (in b+w)
//   all mobile entities use the mask data to assess legal moves
// may eventually need something like A*Star to allow entities to find paths, but keep simple for now

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
  
  // draw ground strata
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
  new PrimordialAge().generate();

  // draw the sky
  fill(61, 174, 197);
  noStroke();
  rect(0, 0, width, groundLevel);
}

float strataToYCoordinate(int _i){
  return _i * layerSize + groundLevel + layerSize/2;
}

PVector pickLocation(){
  return new PVector(random(width), random(groundLevel, height));
}