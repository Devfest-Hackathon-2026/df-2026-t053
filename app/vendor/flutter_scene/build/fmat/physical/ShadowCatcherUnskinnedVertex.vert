// Generated from a .fmat material by flutter_scene. Do not edit.
uniform MaterialParams {
  vec3 shadow_color;
  float shadow_intensity;
  float ao_strength;
  float fade_start;
  float fade_end;
  int catcher_mode;
  vec4 baked_region;
}
material_params;

#define MATERIAL_PARAMS_KEEP_ALIVE (material_params.shadow_color.x)

uniform VertexKeepAlive { vec4 keep_alive; }
vertex_keep_alive;

#define HAS_MATERIAL_VERTEX
#include <material_vertex.glsl>

// Custom interpolants (vertex Vertex() -> fragment Surface()).
out vec3 catcher_local_position;

#line 21

  void Vertex(inout VertexInputs vertex) {
    // Object-space position, for the radial fade from the mesh origin.
    catcher_local_position = vertex.position;
  }

#include <flutter_scene_unskinned_body.glsl>
