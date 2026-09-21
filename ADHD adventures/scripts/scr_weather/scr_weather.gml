// Which weather effect obj_weather_control is currently playing.

#macro WEATHER_NONE      0
#macro WEATHER_RAIN      1
#macro WEATHER_SNOW      2
#macro WEATHER_SANDSTORM 3

// How far past each edge of the view weather is spawned. Big enough that a
// running player never reaches ground the weather has not been seeded over yet.
#macro WEATHER_MARGIN 320

// Weather profile: what kind of weather an area is allowed to roll. Set by
// obj_area_control when the player crosses into an area (open world = RAIN).
#macro WEATHER_PROFILE_CLEAR  0   // never any weather
#macro WEATHER_PROFILE_RAIN   1   // rain may come and go
#macro WEATHER_PROFILE_DESERT 2   // sandstorms may come and go, never rain
#macro WEATHER_PROFILE_SNOW   3   // snow may come and go

// How often the weather re-rolls, and how likely it is to turn on / off.
#macro WEATHER_ROLL_FRAMES  240    // ~4s at 60fps
#macro WEATHER_START_CHANCE 0.35
#macro WEATHER_STOP_CHANCE  0.25

global.weather         = WEATHER_NONE
global.weather_profile = WEATHER_PROFILE_RAIN

// The one weather effect a profile is allowed to produce (NONE = no weather).
function weather_target(_p) {
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return WEATHER_RAIN
        case WEATHER_PROFILE_DESERT: return WEATHER_SANDSTORM
        case WEATHER_PROFILE_SNOW:   return WEATHER_SNOW
        default:                     return WEATHER_NONE
    }
}

// True if weather _w is one the profile _p permits. Used to clear weather that
// the area you just entered doesn't allow (e.g. rain stops the moment you step
// into the desert). WEATHER_NONE is always allowed.
function weather_allowed(_w, _p) {
    if (_w == WEATHER_NONE) return true
    return (_w == weather_target(_p))
}

// One chance to start or stop the current area's weather. Run on a timer by
// obj_weather_control, and once immediately on entering a new area.
function weather_roll() {
    var _target = weather_target(global.weather_profile)
    if (_target == WEATHER_NONE) {
        global.weather = WEATHER_NONE                                  // CLEAR profile
    } else if (global.weather == _target) {
        if (random(1) < WEATHER_STOP_CHANCE)  global.weather = WEATHER_NONE
    } else {
        if (random(1) < WEATHER_START_CHANCE) global.weather = _target
    }
}

/// @func weather_emit(ps, emitter, ptype, per_screen)
/// @desc Spawns one step's worth of a weather particle across a margin-padded
///       box around the view. Filling the whole box, rather than a band on the
///       upwind edge, is what keeps the weather continuous: particles already
///       exist wherever the camera is heading, so there is no gap to run into.
function weather_emit(_ps, _em, _pt, _per_screen) {
    if (_per_screen <= 0) return

    var _v  = world_view_rect()
    var _x1 = _v[0] - WEATHER_MARGIN
    var _y1 = _v[1] - WEATHER_MARGIN
    var _x2 = _v[0] + _v[2] + WEATHER_MARGIN
    var _y2 = _v[1] + _v[3] + WEATHER_MARGIN

    part_emitter_region(_ps, _em, _x1, _x2, _y1, _y2, ps_shape_rectangle, ps_distr_linear)

    // _per_screen is "particles per step that should land on screen". Only
    // view_area/box_area of the box is visible, so scale the burst up to match
    // or the padding would thin the weather out.
    var _scale = ((_x2 - _x1) * (_y2 - _y1)) / max(1, _v[2] * _v[3])
    part_emitter_burst(_ps, _em, _pt, max(1, round(_per_screen * _scale)))
}
