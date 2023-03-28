class Button{
  String label;
  int size, left, top;
  float buttonWidth;
  Boolean highlight = false;
  
  Button(String _label, int _size, int _left, int _top){
    label = _label;
    size = _size;
    left = _left;
    top = _top;
    
    textSize(size);
    buttonWidth = textWidth(label);
  }
  
  void show(){
    textSize(size);
    textAlign(LEFT, TOP);
    
    fill(scheme.systemList);
    rect(left, top, buttonWidth, size);
    
    if (highlight){
      fill(scheme.buttonHighlight);
    } else {
      fill(scheme.pageBackground);
    }
    text(label, left, top);
  }
  
  void mouseHover(){
    if (mouseX > left && mouseX < left + buttonWidth &&
        mouseY > top  && mouseY < top + size){
      highlight = true;          
    } else {
      highlight = false;
    }
  }
}