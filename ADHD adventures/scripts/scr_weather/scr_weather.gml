// Which weather effect obj_weather_control is currently playing.

#macro WEATHER_NONE      0
#macro WEATHER_RAIN      1
#macro WEATHER_SNOW      2
#macro WEATHER_SANDSTORM 3

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

global.weather         = WEATHER_NONE;
global.weather_profile = WEATHER_PROFILE_RAIN;

// The one weather effect a profile is allowed to produce (NONE = no weather).
function weather_target(_p) {
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return WEATHER_RAIN;
        case WEATHER_PROFILE_DESERT: return WEATHER_SANDSTORM;
        case WEATHER_PROFILE_SNOW:   return WEATHER_SNOW;
        default:                     return WEATHER_NONE;
    }
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
    } else if (global.weather == _target) {
        if (random(1) < WEATHER_STOP_CHANCE)  global.weather = WEATHER_NONE;
    } else {
        if (random(1) < WEATHER_START_CHANCE) global.weather = _target;
    }
}
