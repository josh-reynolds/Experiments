// Basic shapes - Distance field
// https://thebookofshaders.com/07/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  st.x *= u_resolution.x/u_resolution.y;
  float d = 0.0;

  // remap the space to -1.0 to 1.0
  st = st * 2.0 - 1.0;

  // make the distance field
  d = length( abs(st) - 0.3 );
  //d = length( min(abs(st) - 0.3, 0.0));
  //d = length( max(abs(st) - 0.3, 0.0));

  // visualize the distance field
  gl_FragColor = vec4(vec3(fract(d * 10.0)), 1.0);

  // drawing with the distance field
  //gl_FragColor = vec4(vec3(step(0.3, d)), 1.0);
  //gl_FragColor = vec4(vec3(step(0.3, d) * step(d, 0.4)), 1.0);
  //gl_FragColor = vec4(vec3(smoothstep(0.3, 0.4, d) *
  //                         smoothstep(0.6, 0.5, d)), 1.0);  
}


