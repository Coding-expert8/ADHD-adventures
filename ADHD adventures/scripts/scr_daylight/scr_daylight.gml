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

/// @func daylight_is_night()
/// @desc True between sunset and sunrise -- i.e. while the moon, not the sun, is
///       the light source shd_daylight draws.
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
