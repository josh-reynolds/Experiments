// Basic shapes - Polar shapes
// https://thebookofshaders.com/07/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(0.0);

  vec2 pos = vec2(0.5) - st;

  float r = length(pos) * 2.0;
  float a = atan(pos.y, pos.x);

  //float f = cos(a * 3.0);
  //float f = abs(cos(a * 3.0));
  //float f = abs(cos(a * 2.5)) * 0.5 + 0.3;
  //float f = abs(cos(a * 12.0) * sin(a * 3.0)) * 0.8 + 0.1;
  float f = smoothstep(-0.5, 1.0, cos(a * 10.0)) * 0.2 + 0.5;

  color = vec3( 1.0 - smoothstep(f, f + 0.02, r) );

  gl_FragColor = vec4(color, 1.0);
}


