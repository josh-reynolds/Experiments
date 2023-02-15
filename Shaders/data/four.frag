// Shaping functions
// https://thebookofshaders.com/05/

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float plot(vec2 st){
  return smoothstep(0.02, 0.0, abs(st.y - st.x));
}

float plot(vec2 st, float pct){
  return smoothstep( pct - 0.02, pct, st.y ) -
         smoothstep( pct, pct + 0.02, st.y );
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution;

  // shaping functions ----------------
//  float y = st.x;
//  float y = pow(st.x, 5.0);
//  float y = step(0.5, st.x);
//  float y = smoothstep(0.1, 0.9, st.x);
//  float y = smoothstep(0.2, 0.5, st.x) - 
//            smoothstep(0.5, 0.8, st.x);

//  float y = sin(st.x);
//  float y = abs(sin(st.x));
//  float tx = st.x + u_time;  float y = abs(sin(tx));
//  float px = st.x * PI + u_time;  float y = abs(sin(px));
//  float tx = st.x * u_time;  float y = abs(sin(tx));
//  float px = st.x * PI + u_time;  float y = abs(sin(px) + 1.0);
//  float px = st.x * PI + u_time;  float y = abs(sin(px) * 2.0);
//  float px = st.x * PI + u_time;  float y = fract(sin(px));
  float px = st.x * PI + u_time;  float y = ceil(sin(px)) + floor(sin(px));

// the following are less interesting in this sketch than the 
// samples due to normalized x values
//float y = mod(st.x, 0.5);
//float y = fract(st.x);
//float y = ceil(st.x);
//float y = floor(st.x);
//float y = sign(st.x);
//float y = abs(st.x);
//float y = clamp(st.x, 0.0, 0.5);
//float y = min(0.0, st.x);
//float y = max(0.0, st.x);

  // greyscale gradient -------------
  vec3 color = vec3(y);

  // plot a line --------------------
//  float pct = plot(st);
  float pct = plot(st, y);
  color = (1.0 - pct) * color + pct * vec3(0.0, 1.0, 0.0);

  gl_FragColor = vec4(color, 1.0);
}


