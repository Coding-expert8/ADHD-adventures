// One quad over the camera view, coloured by shd_daylight under ordinary alpha
// blending: the shader decides what colour the light is and how much of the
// world it covers. The view rect goes in as a uniform so the vertex stage can
// hand the fragment stage screen-space coordinates.
if (global.daylight_strength <= 0 or !shader_is_compiled(shd_daylight)) exit;

var _v  = world_view_rect();
var _vx = _v[0], _vy = _v[1], _vw = _v[2], _vh = _v[3];

shader_set(shd_daylight);
shader_set_uniform_f(u_view, _vx, _vy, _vw, _vh);
shader_set_uniform_f(u_phase, global.daylight_phase);
shader_set_uniform_f(u_aspect, _vw / _vh);
shader_set_uniform_f(u_strength, global.daylight_strength);
draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
shader_reset();
