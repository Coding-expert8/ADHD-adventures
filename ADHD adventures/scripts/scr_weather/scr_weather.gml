// Which weather effect obj_weather_control is currently playing.

#macro WEATHER_NONE      0
#macro WEATHER_RAIN      1
#macro WEATHER_SNOW      2
#macro WEATHER_SANDSTORM 3

// How far past each edge of the view weather is spawned. Big enough that a
// running player never reaches ground the weather has not been seeded over yet.
#macro WEATHER_MARGIN 320

global.weather = WEATHER_NONE;

/// @func weather_emit(ps, emitter, ptype, per_screen)
/// @desc Spawns one step's worth of a weather particle across a margin-padded
///       box around the view. Filling the whole box, rather than a band on the
///       upwind edge, is what keeps the weather continuous: particles already
///       exist wherever the camera is heading, so there is no gap to run into.
function weather_emit(_ps, _em, _pt, _per_screen) {
    if (_per_screen <= 0) return;

    var _v  = world_view_rect();
    var _x1 = _v[0] - WEATHER_MARGIN;
    var _y1 = _v[1] - WEATHER_MARGIN;
    var _x2 = _v[0] + _v[2] + WEATHER_MARGIN;
    var _y2 = _v[1] + _v[3] + WEATHER_MARGIN;

    part_emitter_region(_ps, _em, _x1, _x2, _y1, _y2, ps_shape_rectangle, ps_distr_linear);

    // _per_screen is "particles per step that should land on screen". Only
    // view_area/box_area of the box is visible, so scale the burst up to match
    // or the padding would thin the weather out.
    var _scale = ((_x2 - _x1) * (_y2 - _y1)) / max(1, _v[2] * _v[3]);
    part_emitter_burst(_ps, _em, _pt, max(1, round(_per_screen * _scale)));
}
