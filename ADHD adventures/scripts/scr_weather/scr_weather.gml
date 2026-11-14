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

// How often the weather re-rolls its on/off state.
#macro WEATHER_ROLL_FRAMES 240    // ~4s at 60fps

// Weather is scheduled per profile, as a spell rather than a coin flip every
// roll: once it starts it runs for at least its minimum, and only then do the
// stop rolls begin. Without the minimum, a 4s roll interval means showers that
// blink on and off every few seconds.
//
// Start chances are per roll, so the expected wait for weather to arrive is
// WEATHER_ROLL_FRAMES / chance -- and the expected spell is the minimum plus
// WEATHER_ROLL_FRAMES / stop chance.
#macro WEATHER_RAIN_START_CHANCE 0.09   // ~45s of clear between showers
#macro WEATHER_RAIN_STOP_CHANCE  0.25
#macro WEATHER_RAIN_MIN_FRAMES   1800   // 30s before a shower may even start to break up

#macro WEATHER_SAND_START_CHANCE 0.45   // deserts are storm-prone: ~9s of calm between
#macro WEATHER_SAND_STOP_CHANCE  0.2
#macro WEATHER_SAND_MIN_FRAMES   1500   // 25s

// Ambience levels for each weather. Relative to SFX_VOLUME's full scale, so a
// value above 1 amplifies the clip rather than just un-attenuating it.
#macro WEATHER_RAIN_VOLUME 0.9
#macro WEATHER_SAND_VOLUME 1.2

// How much of the world each wash covers at full strength.
#macro AIR_RAIN_COVER   0.15
#macro AIR_SAND_COVER   0.11
#macro AIR_DESERT_COVER 0.14
#macro AIR_TOWN_COVER   0.3

// How quickly the air tint eases towards the one it should be, per step. About a
// second and a half to arrive, which is slow enough to read as walking into
// somewhere rather than the screen changing colour.
#macro AIR_TINT_FADE 0.03

global.weather         = WEATHER_NONE;
global.weather_profile = WEATHER_PROFILE_RAIN;

// Frames left of the current spell's guaranteed run. While this is above zero
// weather_roll will not turn the weather off. Counted down by weather_hold_step.
global.weather_hold = 0;

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
    return (_p == WEATHER_PROFILE_TOWN) or (_p == WEATHER_PROFILE_SNOW);
}

/// @func weather_start_chance(profile)
/// @desc Chance per roll that this profile's weather arrives.
function weather_start_chance(_p) {
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return WEATHER_RAIN_START_CHANCE;
        case WEATHER_PROFILE_DESERT: return WEATHER_SAND_START_CHANCE;
        default:                     return 0;
    }
}

/// @func weather_stop_chance(profile)
/// @desc Chance per roll that a spell breaks up, once past its minimum.
function weather_stop_chance(_p) {
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return WEATHER_RAIN_STOP_CHANCE;
        case WEATHER_PROFILE_DESERT: return WEATHER_SAND_STOP_CHANCE;
        default:                     return 1;   // unscheduled weather stops at the first roll
    }
}

/// @func weather_min_frames(profile)
/// @desc How long a spell is guaranteed to run before it may start breaking up.
function weather_min_frames(_p) {
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return WEATHER_RAIN_MIN_FRAMES;
        case WEATHER_PROFILE_DESERT: return WEATHER_SAND_MIN_FRAMES;
        default:                     return 0;
    }
}

/// @func weather_hold_step()
/// @desc Runs down the current spell's guaranteed stretch. Run every step by
///       obj_weather_control. Also self-corrects: anything that clears
///       global.weather directly (obj_area_control does, on an area boundary)
///       drops the hold with it rather than leaving it to protect a spell that
///       is no longer running.
function weather_hold_step() {
    if (global.weather == WEATHER_NONE) {
        global.weather_hold = 0;
        return;
    }
    if (global.weather_hold > 0) global.weather_hold--;
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
    var _p      = global.weather_profile;
    var _target = weather_target(_p);

    if (_target == WEATHER_NONE) {
        global.weather      = WEATHER_NONE;                             // CLEAR profile
        global.weather_hold = 0;
    } else if (weather_profile_permanent(_p)) {
        global.weather      = _target;                                  // and it stays on
        global.weather_hold = 0;
    } else if (global.weather == _target) {
        // A spell runs its minimum before it is allowed to break up. Crossing
        // into another area of the same profile re-rolls immediately, so without
        // this check a long walk through rainy country could cut a shower short
        // at every boundary.
        if (global.weather_hold > 0) return;
        if (random(1) < weather_stop_chance(_p)) global.weather = WEATHER_NONE;
    } else {
        if (random(1) < weather_start_chance(_p)) {
            global.weather      = _target;
            global.weather_hold = weather_min_frames(_p);
        }
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

    // A running sandstorm is thick with dust, well past the haze a desert
    // carries on a calm day. This wash over the area's own is most of what makes
    // the storm read as fog rather than as fast-moving grit.
    if (_w == WEATHER_SANDSTORM) return air_tint_make(0.82, 0.70, 0.49, AIR_SAND_COVER);

    // Snow has no wash of its own: a SNOW area reads cold from the flakes
    // themselves. Give it one here if it should have one.
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
