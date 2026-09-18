// Weather roll: every ~8s, roll whether the weather the current area allows
// (global.weather_profile) starts or stops. Weather is a chance, never forced.

var _target = WEATHER_NONE;
switch (global.weather_profile) {
    case WEATHER_PROFILE_RAIN:   _target = WEATHER_RAIN;      break;
    case WEATHER_PROFILE_DESERT: _target = WEATHER_SANDSTORM; break;
    case WEATHER_PROFILE_SNOW:   _target = WEATHER_SNOW;      break;
}

if (_target == WEATHER_NONE) {
    // CLEAR profile: this area never has weather.
    global.weather = WEATHER_NONE;
} else if (global.weather == _target) {
    if (random(1) < 0.30) global.weather = WEATHER_NONE;   // chance to clear
} else {
    if (random(1) < 0.20) global.weather = _target;        // chance to start
}

alarm[0] = 480; // ~8s at 60fps; roll again
