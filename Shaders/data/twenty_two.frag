// Patterns - Truchet tiles
// https://thebookofshaders.com/09/

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265358979323846

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 rotate2D (vec2 _st, float _angle){
  _st -= 0.5;
  _st = mat2(cos(_angle), -sin(_angle),
             sin(_angle), cos(_angle)) * _st;
  _st += 0.5;
  return _st;
}

vec2 tile (vec2 _st, float _zoom){
  _st *= _zoom;
  return fract(_st);
}

vec2 rotateTilePattern(vec2 _st){
  // scale the coordinate system by 2x2
  _st *= 2.0;

  // give each cell an index number by position
  float index = 0.0;
  index += step(1.0, mod(_st.x, 2.0));
  index += step(1.0, mod(_st.y, 2.0)) * 2.0;

  //     |   
  //  2  |  3
  //     |  
  //-----------
  //     |  
  //  0  |  1
  //     |

  // make each cell between 0.0 - 1.0
  _st = fract(_st);

  // rotate each cell according to the index
  if (index == 1.0){
    _st = rotate2D(_st, PI * 0.5);
  } else if (index == 2.0){
    _st = rotate2D(_st, PI * -0.5);
  } else if (index == 3.0){
    _st = rotate2D(_st, PI);
  }

  return _st; 
}

void main() {
  vec2 st = gl_FragCoord.xy / u_resolution.xy;

  st = tile(st, 3.0);
  st = rotateTilePattern(st);

  // more interesting combinations
  //st = tile(st, 2.0);
  //st = rotate2D(st, -PI * u_time * 0.25);
  //st = rotateTilePattern(st * 2.0);
  //st = rotate2D(st, PI * u_time * 0.25);

  // step(st.x, st.y) just makes b&w triangles
  // can substitute other designs...
  gl_FragColor = vec4(vec3(step(st.x, st.y)), 1.0);
}


