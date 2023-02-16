// Basic shapes
// https://thebookofshaders.com/07/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(0.0);

  // each result will return 1.0 (white) or 0.0 (black)
  //float left = step(0.1, st.x);   // similar to (x > 0.1)
  //float bottom = step(0.1, st.y); // similar to (y > 0.1)

  // handling both step() calls in one operation:
  vec2 borders = step(vec2(0.1), st);
  float pct = borders.x * borders.y;

  // adding top + right borders
  vec2 tr = step(vec2(0.1), 1.0 - st);
  pct *= tr.x * tr.y;

  // multiplication of left * bottom similar to logical AND
  //color = vec3( left * bottom );
  color = vec3(pct);

  gl_FragColor = vec4(color, 1.0);
}


