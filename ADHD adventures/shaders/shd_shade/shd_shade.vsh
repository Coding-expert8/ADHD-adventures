//
// Shade region -- vertex stage.
//
// One quad over a marked-out patch of ground. Turning each corner's room
// position into a 0..1 position inside that patch here is what lets the fragment
// stage soften the edges without the quad needing a texture to carry UVs. Same
// trick as shd_daylight, with the region standing in for the camera view.
//
attribute vec3 in_Position;                  // (x,y,z)

uniform vec4 u_rect;                         // the region in room space: x, y, width, height

varying vec2 v_pos;                          // (0,0) = its top left, (1,1) = its bottom right

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    v_pos = (in_Position.xy - u_rect.xy) / u_rect.zw;
}
