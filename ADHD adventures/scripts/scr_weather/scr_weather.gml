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

global.weather         = WEATHER_NONE;
global.weather_profile = WEATHER_PROFILE_RAIN;

// True if weather _w is one the profile _p permits. Used to clear weather that
// the area you just entered doesn't allow (e.g. rain stops the moment you step
// into the desert). WEATHER_NONE is always allowed.
function weather_allowed(_w, _p) {
    if (_w == WEATHER_NONE) return true;
    switch (_p) {
        case WEATHER_PROFILE_RAIN:   return (_w == WEATHER_RAIN);
        case WEATHER_PROFILE_DESERT: return (_w == WEATHER_SANDSTORM);
        case WEATHER_PROFILE_SNOW:   return (_w == WEATHER_SNOW);
        default:                     return false; // CLEAR
    }
}
