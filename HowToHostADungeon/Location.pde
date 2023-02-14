class Location {
  String label;
  PVector coord;
  PVector start;
  PVector end;

  Location(String _label, PVector _location) {
    label = _label;
    coord = _location;
    start = null;
    end = null;
  }

  Location(String _label, PVector _start, PVector _end) {
    label = _label;
    start = _start;
    end = _end;
    
    PVector direction = PVector.sub(end, start);
    direction.mult(random(0.1, 0.9));
    coord = new PVector(direction.x + start.x, direction.y + start.y);
  }

  String toString() {
    return label + " (" + coord.x + ", " + coord.y + ")";
  }
}