//
// Day/night overlay -- vertex stage.
//
// The overlay is one quad stretched over the camera view. Turning each corner's
// room position into a 0..1 view coordinate here means the fragment stage can
// work in screen space without the quad needing a texture to carry UVs.
//
attribute vec3 in_Position;                  // (x,y,z)

uniform vec4 u_view;                         // camera rect in room space: x, y, width, height

varying vec2 v_pos;                          // (0,0) = top left of the view, (1,1) = bottom right

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;

    v_pos = (in_Position.xy - u_view.xy) / u_view.zw;
}
