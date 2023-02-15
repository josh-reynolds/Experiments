// Using pixel & mouse coordinates
// https://thebookofshaders.com/03/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
  vec2 st = gl_FragCoord.xy/u_resolution;
  vec2 mouse = u_mouse/u_resolution;
  //gl_FragColor = vec4(st.x, st.y, 0.0, 1.0);
  //gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
  //gl_FragColor = vec4(mouse.x, mouse.y, 0.0, 1.0);
  gl_FragColor = vec4(mouse.x, mouse.y, abs(sin(u_time)), 1.0);
}


