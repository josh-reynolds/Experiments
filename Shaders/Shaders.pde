// Working through examples from  
//   https://thebookofshaders.com/

// skeleton for working with shaders in Processing is here:
//   https://thebookofshaders.com/04/
// ------------------------------------------------

// check data folder in this sketch for more shaders
String shaderFile = "three.frag";
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