// Basic shapes - Circles
// https://thebookofshaders.com/07/

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float circle(vec2 center, float radius, vec2 px){
  float pct = distance(px, center);
  //float pct = distance(px, vec2(0.4)) + distance(px, vec2(0.6));
  //float pct = distance(px, vec2(0.4)) * distance(px, vec2(0.6));
  //float pct = min(distance(px, vec2(0.4)), distance(px, vec2(0.6)));
  //float pct = max(distance(px, vec2(0.4)), distance(px, vec2(0.6)));
  //float pct = pow(distance(px, vec2(0.4)), distance(px, vec2(0.6)));

  return step(radius, pct);
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  //float pct = 0.0;

  // a. the DISTANCE from the pixel to the center
  //pct = distance(st, vec2(0.5));

  // b. the LENGTH of the vector from pixel to center
  //vec2 toCenter = vec2(0.5) - st;
  //pct = length(toCenter);

  // c. the SQUARE ROOT of the vector from pixel to center
  //vec2 tC = vec2(0.5) - st;
  //pct = sqrt(tC.x * tC.x + tC.y * tC.y);

  float radius = 0.3;

  // black circle on white background
  //float c = step(radius, pct);
  // white circle on black background
  //float c = abs(1.0 - step(radius, pct));
  //vec3 color = vec3(c);

  vec2 center = vec2(0.2, 0.2);

  // black circle via function call
  //vec3 color = vec3(circle(center, radius, st));
  // white circle via function call
  vec3 color = vec3(abs(1.0 - circle(center, radius, st)));

  // tint all pixels blue
  vec3 blue = vec3(0.0, 0.0, 1.0);
  color *= blue;

  gl_FragColor = vec4(color, 1.0);
}


