// The day/night cycle obj_daylight_control plays through shd_daylight.

// One full day -- midnight to midnight -- takes ten minutes of real time.
#macro DAYLIGHT_CYCLE_MINUTES 10
#macro DAYLIGHT_CYCLE_FRAMES  (DAYLIGHT_CYCLE_MINUTES * 60 * 60)   // 36000 steps at 60fps

// Time of day the cycle starts at, so the map opens in clear mid-morning light
// rather than halfway through the night.
#macro DAYLIGHT_START_HOUR 8

// Holding D runs the clock this much faster -- a whole day in 30 seconds instead
// of ten minutes -- so you can see how somewhere reads at dusk without waiting.
#macro DAYLIGHT_FAST_KEY   ord("D")
#macro DAYLIGHT_FAST_SCALE 20

// Where we are in the day, 0..1: 0 = midnight, 0.25 = sunrise, 0.5 = noon,
// 0.75 = sunset. obj_daylight_control walks this forward one step at a time.
global.daylight_phase = DAYLIGHT_START_HOUR / 24;

// How much of the tint to apply. Drop it to 0 for interiors or cutscenes that
// should ignore the time of day; the clock keeps running underneath.
global.daylight_strength = 1;

/// @func daylight_set_hour(hour)
/// @desc Jumps the cycle to a time of day (0-24, fractions allowed).
function daylight_set_hour(_hour) {
    global.daylight_phase = frac(_hour / 24 + 1);
}

/// @func daylight_hour()
/// @desc The current time of day, in hours past midnight (0-24).
function daylight_hour() {
    return global.daylight_phase * 24;
}

// Alpha of each colour in shd_daylight's tint chain. That alpha is literally how much
// of the world the tint covers, so it is the honest answer to "how dark is it out" --
// 0.66 is as dark as the night ever gets. Keep these in step with the COL_* constants
// in shd_daylight.fsh.
#macro DAYLIGHT_ALPHA_NIGHT 0.66
#macro DAYLIGHT_ALPHA_DAWN  0.22
#macro DAYLIGHT_ALPHA_DAY   0.00
#macro DAYLIGHT_ALPHA_DUSK  0.26

/// @func daylight_smooth(edge0, edge1, value)
/// @desc GLSL's smoothstep, which GML does not have: 0 below edge0, 1 above edge1, and an
///       S-curve between them so both ends meet the flats without a kink. shd_daylight's
///       tint chain is built out of these, so anything that has to fade at the same moment
///       has to be built out of the same ones.
function daylight_smooth(_e0, _e1, _v) {
    var _t = clamp((_v - _e0) / (_e1 - _e0), 0, 1);
    return _t * _t * (3 - 2 * _t);
}

/// @func daylight_darkness()
/// @desc How dark the world is right now, 0 (broad daylight) to 1 (deep night). This walks
///       the same four mixes at the same four thresholds as shd_daylight's tint chain and
///       divides by the night alpha, so a light scaling its brightness by this comes up
///       exactly as the tint comes down instead of switching on at some hour of its own.
///       daylight_strength is folded in on purpose: at 0 the tint is not drawn at all, and
///       lights added over an undarkened world would just be glowing blobs in daylight.
function daylight_darkness() {
    var _p = global.daylight_phase;
    var _a = DAYLIGHT_ALPHA_NIGHT;
    _a = lerp(_a, DAYLIGHT_ALPHA_DAWN,  daylight_smooth(0.15, 0.24, _p));
    _a = lerp(_a, DAYLIGHT_ALPHA_DAY,   daylight_smooth(0.29, 0.38, _p));
    _a = lerp(_a, DAYLIGHT_ALPHA_DUSK,  daylight_smooth(0.63, 0.75, _p));
    _a = lerp(_a, DAYLIGHT_ALPHA_NIGHT, daylight_smooth(0.81, 0.93, _p));
    return (_a / DAYLIGHT_ALPHA_NIGHT) * global.daylight_strength;
}

/// @func daylight_is_night()
/// @desc True between sunset and sunrise -- i.e. while the moon, not the sun, is
///       the light source shd_daylight draws. This is a hard clock boundary; for anything
///       that should fade rather than flip, like a lamp coming up at dusk, use
///       daylight_darkness() instead.
function daylight_is_night() {
    return (global.daylight_phase < 0.25 or global.daylight_phase >= 0.75);
}

/// @func daylight_clock_string()
/// @desc The time of day as "HH:MM", for the F1 debug readout.
function daylight_clock_string() {
    var _mins = floor(global.daylight_phase * 24 * 60);
    var _h = _mins div 60;
    var _m = _mins mod 60;
    return (_h < 10 ? "0" : "") + string(_h) + ":" + (_m < 10 ? "0" : "") + string(_m);
}
