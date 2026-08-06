#version 460 core
#include <flutter/runtime_effect.glsl>

// Vidro líquido: refração de borda + concentração de luz na borda.
//
// A engine preenche o PRIMEIRO uniforme (vec2) com o tamanho da textura de
// entrada e liga o primeiro sampler ao que está atrás da peça. Como o filtro
// roda sobre o recorte da própria peça, essa textura é o retângulo do vidro —
// dá para calcular o contorno em coordenadas locais.
//
// Duas coisas acontecem perto do contorno, como em vidro de verdade:
// a luz entorta (a amostra é puxada na direção da normal, com dispersão
// cromática) e a luz se concentra (a cor que atravessa fica mais viva e mais
// clara na borda do que no miolo).

uniform vec2 uTextureSize;
uniform float uRadius;         // raio do canto, em pixels
uniform float uRim;            // espessura da borda que refrata, em pixels
uniform float uStrength;       // deslocamento máximo, em pixels
uniform float uChroma;         // separação dos canais (0 = sem dispersão)
uniform float uEdgeSaturation; // saturação extra na borda
uniform float uEdgeGain;       // ganho de luz na borda
uniform float uBodySaturation; // saturação do miolo

uniform sampler2D uTexture;

out vec4 fragColor;

float sdRoundedBox(vec2 p, vec2 halfSize, float radius) {
  vec2 q = abs(p) - halfSize + radius;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - radius;
}

vec4 sampleAt(vec2 pixel) {
  vec2 uv = pixel / uTextureSize;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(uTexture, clamp(uv, vec2(0.0), vec2(1.0)));
}

void main() {
  vec2 pixel = FlutterFragCoord().xy;
  vec2 halfSize = uTextureSize * 0.5;
  vec2 p = pixel - halfSize;

  float radius = min(uRadius, min(halfSize.x, halfSize.y));
  float distance = sdRoundedBox(p, halfSize, radius);

  // Gradiente do contorno: a normal por onde a luz entra.
  const float epsilon = 1.0;
  vec2 normal = vec2(
    sdRoundedBox(p + vec2(epsilon, 0.0), halfSize, radius) -
        sdRoundedBox(p - vec2(epsilon, 0.0), halfSize, radius),
    sdRoundedBox(p + vec2(0.0, epsilon), halfSize, radius) -
        sdRoundedBox(p - vec2(0.0, epsilon), halfSize, radius)
  );
  float len = length(normal);
  normal = len > 0.0001 ? normal / len : vec2(0.0);

  // 0 no miolo, 1 na borda: só a faixa do contorno entorta e concentra luz.
  float depth = clamp(-distance / max(uRim, 0.001), 0.0, 1.0);
  float edge = pow(1.0 - depth, 2.2);
  vec2 offset = normal * edge * uStrength;

  vec4 color;
  color.r = sampleAt(pixel + offset * (1.0 + uChroma)).r;
  color.g = sampleAt(pixel + offset).g;
  color.b = sampleAt(pixel + offset * (1.0 - uChroma)).b;
  color.a = sampleAt(pixel + offset).a;

  // Concentração: a cor que atravessa fica mais viva e mais clara na borda.
  vec3 rgb = color.rgb;
  float luma = dot(rgb, vec3(0.2126, 0.7152, 0.0722));
  float saturation = uBodySaturation + uEdgeSaturation * edge;
  rgb = mix(vec3(luma), rgb, saturation);
  rgb *= 1.0 + uEdgeGain * edge;

  fragColor = vec4(clamp(rgb, 0.0, 1.0), color.a);
}
