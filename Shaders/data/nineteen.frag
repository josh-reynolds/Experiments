// Patterns - simple tiles
// https://thebookofshaders.com/09/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float circle(in vec2 _st, in float _radius){
  vec2 l = _st - vec2(0.5);
  return 1.0 - smoothstep(_radius - (_radius * 0.01),
                          _radius + (_radius * 0.01),
                          dot(l, l) * 4.0);
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  vec3 color = vec3(0.0);

  st *= 3.0;        // scale up the space by 3
  st = fract(st);   // wrap around 1.0
  // now we have 9 spaces that go from 0-1

  //color = vec3(st, 0.0);
  color = vec3(circle(st, 0.5));

  gl_FragColor = vec4(color, 1.0);
}


