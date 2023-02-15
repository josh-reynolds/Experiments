// Using clock time
// https://thebookofshaders.com/03/

#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;

void main() {
  gl_FragColor = vec4(abs(sin(u_time / 3)), 
                      abs(cos(u_time)), 
                      abs(tan(u_time * 2)), 
                      1.0);
}


