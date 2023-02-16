// Basic shapes
// https://thebookofshaders.com/07/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

float rectangle(float _l, float _r, float _t, float _b, vec2 st){
  float left   = step(_l, st.x);
  float right  = step(_r, 1.0 - st.x);
  float top    = step(_t, 1.0 - st.y);
  float bottom = step(_b, st.y);

  return left * right * top * bottom;
}

float outline(float _l, float _r, float _t, float _b, float _w, vec2 st){
  float rect = rectangle(_l, _r, _t, _b, st);
  float interior = abs(1.0 - rectangle(_l + _w, _r + _w, _t + _w, _b + _w, st));

  return rect * interior;
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(0.0);

  //color = vec3(rectangle(0.1, 0.1, 0.1, 0.1, st));
  //color = vec3(rectangle(0.4, 0.2, 0.3, 0.05, st));

  // inverted rectangle
  //color = vec3(abs(1.0 - rectangle(0.4, 0.2, 0.3, 0.01, st)));

  // outlined rectangle
  color = vec3(outline(0.1, 0.1, 0.1, 0.1, 0.01, st));

  // coloring the rectangle
  color *= vec3(0.0, 0.0, 1.0);

  gl_FragColor = vec4(color, 1.0);
}


