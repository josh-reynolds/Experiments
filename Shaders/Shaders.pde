// Working through examples from  
//   https://thebookofshaders.com/

// skeleton for working with shaders in Processing is here:
//   https://thebookofshaders.com/04/
// ---------------------------------------------------------------------
//  one.frag    Hello World             https://thebookofshaders.com/02/
//  two.frag    System clock time       https://thebookofshaders.com/03/
//  three.frag  Pixel/Mouse coordinates https://thebookofshaders.com/03/
//  four.frag   Shaping functions       https://thebookofshaders.com/05/
//  five.frag   Color mixing            https://thebookofshaders.com/06/
//  six.frag    Color gradients         https://thebookofshaders.com/06/
//  seven.frag  HSB                     https://thebookofshaders.com/06/
// ---------------------------------------------------------------------

String shaderFile = "seven.frag";
PShader shader;

void setup(){
  size(400, 400, P2D);
  //noStroke();    // included in example, not yet seeing a difference
  
  shader = loadShader(shaderFile);
}

void draw(){
  shader.set("u_resolution", float(width), float(height));
  shader.set("u_time", millis() / 1000.0);
  
  // y-axis in shader is inverted from Processing: 0,0 is bottom-left corner
  shader.set("u_mouse", float(mouseX), float(height - mouseY)); 
  
  shader(shader);
  rect(0, 0, width, height);
}

void mouseMoved(){
  println(mouseX + ", " + mouseY + ": " + hex(get(mouseX, mouseY)));
}