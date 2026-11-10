// Generated from a .fmat material by flutter_scene. Do not edit.
#define FLUTTER_SCENE_SKIP_SHADOWS
#define FLUTTER_SCENE_RADIANCE_CUBE
#define FLUTTER_SCENE_PHYSICAL_MATERIAL
#define FLUTTER_SCENE_DEFAULT_FLOAT_PRECISION mediump
precision mediump float;
precision highp int;
#include <material_varyings.glsl>
#include <pbr.glsl>
#include <texture.glsl>
#include <normals.glsl>
#include <material_inputs.glsl>
#include <material_debug.glsl>
#include <material_engine_lighting.glsl>
#include <material_lighting.glsl>

uniform MaterialParams {
  highp vec4 base_color_factor;
  highp float metallic_factor;
  highp float roughness_factor;
  highp float normal_scale;
  highp float occlusion_strength;
  highp int alpha_mode;
  highp float alpha_cutoff;
  highp vec3 emissive_factor;
  highp float emissive_strength;
  highp float specular_factor;
  highp vec3 specular_color_factor;
  highp float ior;
  highp float clearcoat;
  highp float clearcoat_roughness;
  highp vec2 clearcoat_normal_scale;
  highp vec3 sheen_color;
  highp float sheen_roughness;
  highp float transmission;
  highp float diffuse_transmission;
  highp vec3 diffuse_transmission_color;
  highp float thickness;
  highp vec3 attenuation_color;
  highp float attenuation_distance;
  highp float dispersion;
  highp float iridescence;
  highp float iridescence_ior;
  highp float iridescence_thickness_minimum;
  highp float iridescence_thickness_maximum;
  highp float anisotropy;
  highp float anisotropy_rotation;
  highp int feature_a;
  highp int feature_b;
  highp int feature_c;
  highp vec4 base_color_uv_transform;
  highp float base_color_uv_rotation;
  highp int base_color_uv_set;
  highp vec4 metallic_roughness_uv_transform;
  highp float metallic_roughness_uv_rotation;
  highp int metallic_roughness_uv_set;
  highp vec4 normal_uv_transform;
  highp float normal_uv_rotation;
  highp int normal_uv_set;
  highp vec4 feature_a_uv_transform;
  highp float feature_a_uv_rotation;
  highp int feature_a_uv_set;
  highp vec4 feature_b_uv_transform;
  highp float feature_b_uv_rotation;
  highp int feature_b_uv_set;
  highp vec4 feature_c_uv_transform;
  highp float feature_c_uv_rotation;
  highp int feature_c_uv_set;
}
material_params;

uniform FragmentKeepAlive { vec4 keep_alive; }
fragment_keep_alive;

uniform sampler2D base_color_texture;
uniform sampler2D metallic_roughness_texture;
uniform sampler2D normal_texture;
uniform sampler2D feature_texture_a;
uniform sampler2D feature_texture_b;
uniform sampler2D feature_texture_c;

#line 67

  void ApplyFeature(inout MaterialInputs material, int feature, vec4 sampled,
                    vec2 uv) {
    if (feature == 1) {
      material.emissive *= SRGBToLinear(sampled.rgb);
    }
    if (feature == 2) {
      material.occlusion = 1.0 -
          (1.0 - sampled.r) * material_params.occlusion_strength;
    }
    if (feature == 3) material.specular_weight *= sampled.a;
    if (feature == 4) material.specular_color *= SRGBToLinear(sampled.rgb);
    if (feature == 5) material.clearcoat *= sampled.r;
    if (feature == 6) material.clearcoat_roughness *= sampled.g;
    if (feature == 8) material.sheen_color *= SRGBToLinear(sampled.rgb);
    if (feature == 9) material.sheen_roughness *= sampled.a;
    if (feature == 10) material.iridescence *= sampled.r;
    if (feature == 11) {
      material.iridescence_thickness = mix(
          material_params.iridescence_thickness_minimum,
          material_params.iridescence_thickness_maximum, sampled.g);
    }
    if (feature == 12) {
      vec2 direction = sampled.rg * 2.0 - 1.0;
      float length_squared = dot(direction, direction);
      if (length_squared > 1e-5) {
        direction *= inversesqrt(length_squared);
      } else {
        direction = vec2(1.0, 0.0);
      }
      float c = cos(material_params.anisotropy_rotation);
      float s = sin(material_params.anisotropy_rotation);
      material.anisotropy_direction =
          vec2(c * direction.x - s * direction.y,
               s * direction.x + c * direction.y);
      material.anisotropy *= sampled.b;
      material.anisotropy_uv = uv;
    }
    if (feature == 13) material.diffuse_transmission *= sampled.a;
    if (feature == 14) {
      material.diffuse_transmission_color *= SRGBToLinear(sampled.rgb);
    }
  }

  void Surface(inout MaterialInputs material) {
    vec2 base_uv = ApplyMaterialUvTransform(
        GetUV(material_params.base_color_uv_set),
        material_params.base_color_uv_transform,
        material_params.base_color_uv_rotation);
    vec2 mr_uv = ApplyMaterialUvTransform(
        GetUV(material_params.metallic_roughness_uv_set),
        material_params.metallic_roughness_uv_transform,
        material_params.metallic_roughness_uv_rotation);
    vec2 normal_uv = ApplyMaterialUvTransform(
        GetUV(material_params.normal_uv_set),
        material_params.normal_uv_transform,
        material_params.normal_uv_rotation);

    vec4 base = texture(base_color_texture, base_uv);
    vec4 vertex_color = GetVertexColor();
    vec3 color = SRGBToLinear(base.rgb) * vertex_color.rgb *
                 material_params.base_color_factor.rgb;
    float alpha = base.a * vertex_color.a *
                  material_params.base_color_factor.a;
    // MASK renders opaque; the main pass's coverage pre-draw cuts it out.
    if (material_params.alpha_mode == 1) {
      alpha = 1.0;
    }
    material.base_color = vec4(color, alpha);

    vec4 mr = texture(metallic_roughness_texture, mr_uv);
    material.metallic = clamp(mr.b * material_params.metallic_factor, 0.0, 1.0);
    material.roughness = clamp(mr.g * material_params.roughness_factor,
                               kMinRoughness, 1.0);
    material.normal = PerturbNormal(normal_texture, GetWorldNormal(),
                                    v_viewvector, normal_uv,
                                    material_params.normal_scale);
    material.emissive = material_params.emissive_factor *
                        material_params.emissive_strength;

    material.specular_weight = material_params.specular_factor;
    material.specular_color = material_params.specular_color_factor;
    material.ior = material_params.ior;
    material.clearcoat = material_params.clearcoat;
    material.clearcoat_roughness = material_params.clearcoat_roughness;
    material.clearcoat_normal = GetWorldNormal();
    material.sheen_color = material_params.sheen_color;
    material.sheen_roughness = material_params.sheen_roughness;
    material.diffuse_transmission = material_params.diffuse_transmission;
    material.diffuse_transmission_color =
        material_params.diffuse_transmission_color;
    material.anisotropy = clamp(material_params.anisotropy, 0.0, 1.0);
    material.anisotropy_direction =
        vec2(cos(material_params.anisotropy_rotation),
             sin(material_params.anisotropy_rotation));
    material.iridescence = material_params.iridescence;
    material.iridescence_ior = material_params.iridescence_ior;
    material.iridescence_thickness =
        material_params.iridescence_thickness_maximum;

    vec2 feature_a_uv = ApplyMaterialUvTransform(
        GetUV(material_params.feature_a_uv_set),
        material_params.feature_a_uv_transform,
        material_params.feature_a_uv_rotation);
    vec2 feature_b_uv = ApplyMaterialUvTransform(
        GetUV(material_params.feature_b_uv_set),
        material_params.feature_b_uv_transform,
        material_params.feature_b_uv_rotation);
    vec2 feature_c_uv = ApplyMaterialUvTransform(
        GetUV(material_params.feature_c_uv_set),
        material_params.feature_c_uv_transform,
        material_params.feature_c_uv_rotation);
    ApplyFeature(material, material_params.feature_a,
                 texture(feature_texture_a, feature_a_uv), feature_a_uv);
    ApplyFeature(material, material_params.feature_b,
                 texture(feature_texture_b, feature_b_uv), feature_b_uv);
    ApplyFeature(material, material_params.feature_c,
                 texture(feature_texture_c, feature_c_uv), feature_c_uv);
    if (material_params.feature_a == 7) {
      material.clearcoat_normal = PerturbNormal(
          feature_texture_a, GetWorldNormal(), v_viewvector, feature_a_uv,
          material_params.clearcoat_normal_scale);
    }
    if (material_params.feature_b == 7) {
      material.clearcoat_normal = PerturbNormal(
          feature_texture_b, GetWorldNormal(), v_viewvector, feature_b_uv,
          material_params.clearcoat_normal_scale);
    }
    if (material_params.feature_c == 7) {
      material.clearcoat_normal = PerturbNormal(
          feature_texture_c, GetWorldNormal(), v_viewvector, feature_c_uv,
          material_params.clearcoat_normal_scale);
    }
    PrepareMaterial(material);
  }

vec4 MaterialOutput(MaterialInputs material) {
  return EvaluateLighting(material);
}

void main() {
  MaterialInputs material = InitMaterialInputs();
  Surface(material);
  vec4 shaded = vec4(0.0);
  if (DebugViewNeedsShaded()) {
    shaded = MaterialOutput(material);
  }
  frag_color = DebugViewOutput(material, shaded);
  if (fragment_keep_alive.keep_alive.x != 0.0) {
    frag_color.r += fragment_keep_alive.keep_alive.x * (material_params.base_color_factor.x + texture(base_color_texture, vec2(0.0)).x + texture(metallic_roughness_texture, vec2(0.0)).x + texture(normal_texture, vec2(0.0)).x + texture(feature_texture_a, vec2(0.0)).x + texture(feature_texture_b, vec2(0.0)).x + texture(feature_texture_c, vec2(0.0)).x);
  }
}
