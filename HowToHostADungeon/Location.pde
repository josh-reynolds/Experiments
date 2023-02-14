class Location {
  String label;
  PVector coord;

  Location(String _label, PVector _location) {
    label = _label;
    coord = _location;
  }

  String toString() {
    return label + " (" + coord.x + ", " + coord.y + ")";
  }
}