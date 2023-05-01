abstract class Screen {
  void drawScreen(){};
}

class Menu extends Screen {
  void drawScreen(){}
}

class Display extends Screen {
  SubsectorDisplay subD;
  TextPanel textPanel;
  
  Display(){
    subD = new SubsectorDisplay();
    textPanel = new TextPanel();
  }
  
  void drawScreen(){
    subD.show(subs);
    textPanel.show(subs);
  }
}