// Which weather effect obj_weather_control is currently playing.

#macro WEATHER_NONE      0
#macro WEATHER_RAIN      1
#macro WEATHER_SNOW      2
#macro WEATHER_SANDSTORM 3

// How far past each edge of the view weather is spawned. Big enough that a
// running player never reaches ground the weather has not been seeded over yet.
#macro WEATHER_MARGIN 320

// Weather profile: what weather an area is allowed to roll, and what colour its
// air is. Set by obj_area_control when the player crosses into an area (open
// world = RAIN).
#macro WEATHER_PROFILE_CLEAR  0   // never any weather
#macro WEATHER_PROFILE_RAIN   1   // rain may come and go
#macro WEATHER_PROFILE_DESERT 2   // sandstorms may come and go, never rain; dusty air
#macro WEATHER_PROFILE_SNOW   3   // snow may come and go
#macro WEATHER_PROFILE_TOWN   4   // rain that never lets up, over grey air
#macro WEATHER_PROFILE_LAST   4   // highest profile there is, for obj_area to clamp to

// How often the weather re-rolls, and how likely it is to turn on / off.
#macro WEATHER_ROLL_FRAMES  240    // ~4s at 60fps
#macro WEATHER_START_CHANCE 0.35
#macro WEATHER_STOP_CHANCE  0.25

// How much of the world each wash covers at full strength.
#macro AIR_RAIN_COVER   0.15
#macro AIR_DESERT_COVER 0.14
#macro AIR_TOWN_COVER   0.3

// How quickly the air tint eases towards the one it should be, per step. About a
// second and a half to arrive, which is slow enough to read as walking into
// somewhere rather than the screen changing colour.
#macro AIR_TINT_FADE 0.03

global.weather         = WEATHER_NONE;
global.weather_profile = WEATHER_PROFILE_RAIN;

// The air tint being drawn right now, premultiplied (see air_tint below). Eased
// towards air_tint_target() every step by obj_weather_control, and handed to
// shd_daylight by obj_daylight_control, which lays it over the day/night tint.
global.air_tint = [0, 0, 0, 0];

// The one weather effect a profile is allowed to produce (NONE = no weather).
function weather_target(_p) {
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return WEATHER_RAIN;
        case WEATHER_PROFILE_DESERT: return WEATHER_SANDSTORM;
        case WEATHER_PROFILE_SNOW:   return WEATHER_SNOW;
        case WEATHER_PROFILE_TOWN:   return WEATHER_RAIN;
        default:                     return WEATHER_NONE;
    }
}

/// @func weather_profile_permanent(profile)
/// @desc True if this profile's weather never lets up. weather_roll stops rolling
///       for these and just keeps the weather on.
function weather_profile_permanent(_p) {
    return (_p == WEATHER_PROFILE_TOWN);
}

// True if weather _w is one the profile _p permits. Used to clear weather that
// the area you just entered doesn't allow (e.g. rain stops the moment you step
// into the desert). WEATHER_NONE is always allowed.
function weather_allowed(_w, _p) {
    if (_w == WEATHER_NONE) return true;
    return (_w == weather_target(_p));
}

// One chance to start or stop the current area's weather. Run on a timer by
// obj_weather_control, and once immediately on entering a new area.
function weather_roll() {
    var _target = weather_target(global.weather_profile);
    if (_target == WEATHER_NONE) {
        global.weather = WEATHER_NONE;                                  // CLEAR profile
    } else if (weather_profile_permanent(global.weather_profile)) {
        global.weather = _target;                                       // and it stays on
    } else if (global.weather == _target) {
        if (random(1) < WEATHER_STOP_CHANCE)  global.weather = WEATHER_NONE;
    } else {
        if (random(1) < WEATHER_START_CHANCE) global.weather = _target;
    }
}

// --- air tint -----------------------------------------------------------------
// A colour laid over the view on top of the day/night tint: the look of the air
// in a place, and of the weather hanging in it. An area contributes one through
// its profile and the running weather lays another over the top, so a rainy town
// comes out both grey and wet rather than one or the other.
//
// Tints are stored PREMULTIPLIED -- [r*a, g*a, b*a, a] rather than [r, g, b, a].
// They get crossfaded, and fading straight colours means fading the colour of a
// tint that is not there yet, which drags the screen through whatever sits in the
// rgb slots of a tint with alpha 0 (black, so: through a shadow). Premultiplied,
// "not there" is all zeroes and means it, and a tint fades up in its own colour
// from the first frame.

/// @func air_tint_make(r, g, b, cover)
/// @desc A premultiplied tint from a straight colour and how much it covers.
///       Named _make rather than plain air_tint because a script-level
///       `function foo()` IS the global variable foo in GML -- declaring
///       air_tint() here would quietly overwrite global.air_tint with a method.
function air_tint_make(_r, _g, _b, _a) {
    return [_r * _a, _g * _a, _b * _a, _a];
}

/// @func weather_profile_tint(profile)
/// @desc The colour of an area's own air.
function weather_profile_tint(_p) {
    switch (_p) {
        // Dust and heat standing in the air: warm, sandy, thin enough to read as
        // air rather than as a filter over the lens.
        case WEATHER_PROFILE_DESERT: return air_tint_make(0.85, 0.72, 0.48, AIR_DESERT_COVER);
        // Smoke and wet slate. Barely a colour -- mostly a loss of colour.
        case WEATHER_PROFILE_TOWN:   return air_tint_make(0.02, 0.03, 0.05, AIR_TOWN_COVER);
        default:                     return [0, 0, 0, 0];
    }
}

/// @func weather_tint(weather)
/// @desc The colour the running weather adds over its area's own.
function weather_tint(_w) {
    // Rain draws the warmth out of everything it falls on.
    if (_w == WEATHER_RAIN) return air_tint_make(0.42, 0.50, 0.60, AIR_RAIN_COVER);

    // Snow and sandstorms have no wash of their own: a SNOW area reads cold from
    // the flakes themselves, and a DESERT one already carries dust in its air.
    // Give them one here if they should have it.
    return [0, 0, 0, 0];
}

/// @func air_tint_over(under, on_top)
/// @desc Lays one premultiplied tint over another. Premultiplied is why this is
///       two lines and not a page: the top one contributes itself, and the one
///       underneath contributes whatever the top one lets through.
function air_tint_over(_u, _t) {
    var _k = 1 - _t[3];
    return [_t[0] + _u[0] * _k, _t[1] + _u[1] * _k, _t[2] + _u[2] * _k, _t[3] + _u[3] * _k];
}

/// @func air_tint_target()
/// @desc The tint the air should have right now: the area's, with the weather's
///       laid over it.
function air_tint_target() {
    return air_tint_over(weather_profile_tint(global.weather_profile), weather_tint(global.weather));
}

/// @func air_tint_step()
/// @desc Eases the live tint towards the target. Run every step by
///       obj_weather_control. Crossing an area boundary or a shower starting
///       moves the target in a single frame; without this the whole screen would
///       change colour in that frame too.
function air_tint_step() {
    var _t = air_tint_target();
    for (var _i = 0; _i < 4; _i++) {
        global.air_tint[_i] = lerp(global.air_tint[_i], _t[_i], AIR_TINT_FADE);
    }
}

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
