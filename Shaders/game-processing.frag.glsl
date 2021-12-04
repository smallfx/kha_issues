#version 450
precision mediump float;

uniform sampler2D tex;
in vec2 texCoord;
in vec4 color;

out vec4 FragColor;

uniform float darken;
uniform float brighten;

void main() {
  vec4 texcolor = texture(tex, texCoord);

  texcolor.r = max(0, texcolor.r - darken);
  texcolor.g = max(0, texcolor.g - darken);
  texcolor.b = max(0, texcolor.b - darken);

  texcolor.r = min(1, texcolor.r + brighten);
  texcolor.g = min(1, texcolor.g + brighten);
  texcolor.b = min(1, texcolor.b + brighten);
  
  FragColor = texcolor;
}
