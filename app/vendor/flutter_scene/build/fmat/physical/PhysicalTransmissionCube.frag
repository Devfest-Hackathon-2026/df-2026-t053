// Generated from a .fmat material by flutter_scene. Do not edit.
#define FLUTTER_SCENE_SKIP_SHADOWS
#define FLUTTER_SCENE_RADIANCE_CUBE
#define FLUTTER_SCENE_PHYSICAL_MATERIAL
#define FLUTTER_SCENE_SKIP_SSAO
#define FLUTTER_SCENE_SCENE_COLOR
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
  highp int transmission_texture_kind;
  highp vec4 base_color_uv_transform;
  highp float base_color_uv_rotation;
  highp int base_color_uv_set;
  highp vec4 metallic_roughness_uv_transform;
  highp float metallic_roughness_uv_rotation;
  highp int metallic_roughness_uv_set;
  highp vec4 normal_uv_transform;
  highp float normal_uv_rotation;
  highp int normal_uv_set;
  highp vec4 emissive_uv_transform;
  highp float emissive_uv_rotation;
  highp int emissive_uv_set;
  highp vec4 transmission_data_uv_transform;
  highp float transmission_data_uv_rotation;
  highp int transmission_data_uv_set;
}
material_params;

uniform FragmentKeepAlive { vec4 keep_alive; }
fragment_keep_alive;

uniform sampler2D base_color_texture;
uniform sampler2D metallic_roughness_texture;
uniform sampler2D normal_texture;
uniform sampler2D emissive_texture;
uniform sampler2D transmission_data_texture;

#include <filtered_scene_color.glsl>

#line 63

  vec3 VolumeTransmissionRay(vec3 normal, float thickness, float ior) {
    vec3 ray = refract(-GetViewDirection(), normal,
                       1.0 / max(ior, 1.0));
    return normalize(ray) * thickness * GetModelScale();
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
    vec2 emissive_uv = ApplyMaterialUvTransform(
        GetUV(material_params.emissive_uv_set),
        material_params.emissive_uv_transform,
        material_params.emissive_uv_rotation);
    vec2 data_uv = ApplyMaterialUvTransform(
        GetUV(material_params.transmission_data_uv_set),
        material_params.transmission_data_uv_transform,
        material_params.transmission_data_uv_rotation);

    vec4 base = texture(base_color_texture, base_uv);
    vec4 vertex_color = GetVertexColor();
    material.base_color = vec4(
        SRGBToLinear(base.rgb) * vertex_color.rgb *
            material_params.base_color_factor.rgb,
        base.a * vertex_color.a * material_params.base_color_factor.a);
    vec4 mr = texture(metallic_roughness_texture, mr_uv);
    material.metallic = clamp(mr.b * material_params.metallic_factor, 0.0, 1.0);
    material.roughness = clamp(mr.g * material_params.roughness_factor,
                               kMinRoughness, 1.0);
    material.normal = PerturbNormal(normal_texture, GetWorldNormal(),
                                    v_viewvector, normal_uv,
                                    material_params.normal_scale);
    material.emissive = material_params.emissive_factor *
                        material_params.emissive_strength *
                        SRGBToLinear(texture(emissive_texture,
                                             emissive_uv).rgb);
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

    vec4 data = texture(transmission_data_texture, data_uv);
    float transmission = material_params.transmission;
    float thickness = material_params.thickness;
    if (material_params.transmission_texture_kind == 1) transmission *= data.r;
    if (material_params.transmission_texture_kind == 2) thickness *= data.g;

    float ior = max(material_params.ior, 1.0);
    float half_spread = (ior - 1.0) * 0.025 * material_params.dispersion;
    vec3 iors = vec3(max(ior - half_spread, 1.0), ior,
                     ior + half_spread);
    vec3 ray_r = VolumeTransmissionRay(material.normal, thickness, iors.r);
    vec3 ray_g = VolumeTransmissionRay(material.normal, thickness, iors.g);
    vec3 ray_b = VolumeTransmissionRay(material.normal, thickness, iors.b);
    vec2 screen_uv = GetScreenUv();
    vec2 offset_r = ProjectWorldOffsetToScreenUv(ray_r) - screen_uv;
    vec2 offset_g = ProjectWorldOffsetToScreenUv(ray_g) - screen_uv;
    vec2 offset_b = ProjectWorldOffsetToScreenUv(ray_b) - screen_uv;
    vec3 transmitted;
    transmitted.r = GetSceneColorFiltered(
        offset_r, material.roughness, iors.r).r;
    transmitted.g = GetSceneColorFiltered(
        offset_g, material.roughness, iors.g).g;
    transmitted.b = GetSceneColorFiltered(
        offset_b, material.roughness, iors.b).b;

    float attenuation_distance = max(material_params.attenuation_distance,
                                     1e-4);
    vec3 attenuation = pow(
        max(material_params.attenuation_color, vec3(1e-4)),
        vec3(length(ray_r), length(ray_g), length(ray_b)) /
            attenuation_distance);
    material.transmission = transmission;
    material.transmission_color = transmitted * attenuation;
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
    frag_color.r += fragment_keep_alive.keep_alive.x * (material_params.base_color_factor.x + texture(base_color_texture, vec2(0.0)).x + texture(metallic_roughness_texture, vec2(0.0)).x + texture(normal_texture, vec2(0.0)).x + texture(emissive_texture, vec2(0.0)).x + texture(transmission_data_texture, vec2(0.0)).x + texture(scene_opaque_color, vec2(0.0)).x + texture(scene_filtered_color, vec2(0.0)).x);
  }
}
