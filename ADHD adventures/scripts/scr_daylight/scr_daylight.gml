#macro DAYLIGHT_CYCLE_MINUTES 10
#macro DAYLIGHT_CYCLE_FRAMES  (DAYLIGHT_CYCLE_MINUTES * 60 * 60)

#macro DAYLIGHT_START_HOUR 8

#macro DAYLIGHT_FAST_KEY   ord("D")
#macro DAYLIGHT_FAST_SCALE 20

global.daylight_phase = DAYLIGHT_START_HOUR / 24

global.daylight_strength = 1

function daylight_set_hour(_hour) {
    global.daylight_phase = frac(_hour / 24 + 1)
}

function daylight_hour() {
    return global.daylight_phase * 24
}

#macro DAYLIGHT_ALPHA_NIGHT 0.66
#macro DAYLIGHT_ALPHA_DAWN  0.22
#macro DAYLIGHT_ALPHA_DAY   0.00
#macro DAYLIGHT_ALPHA_DUSK  0.26

function daylight_smooth(_e0, _e1, _v) {
    var _t = clamp((_v - _e0) / (_e1 - _e0), 0, 1)
    return _t * _t * (3 - 2 * _t)
}

function daylight_darkness() {
    var _p = global.daylight_phase
    var _a = DAYLIGHT_ALPHA_NIGHT
    _a = lerp(_a, DAYLIGHT_ALPHA_DAWN,  daylight_smooth(0.15, 0.24, _p))
    _a = lerp(_a, DAYLIGHT_ALPHA_DAY,   daylight_smooth(0.29, 0.38, _p))
    _a = lerp(_a, DAYLIGHT_ALPHA_DUSK,  daylight_smooth(0.63, 0.75, _p))
    _a = lerp(_a, DAYLIGHT_ALPHA_NIGHT, daylight_smooth(0.81, 0.93, _p))
    return (_a / DAYLIGHT_ALPHA_NIGHT) * global.daylight_strength
}

function daylight_is_night() {
    return (global.daylight_phase < 0.25 or global.daylight_phase >= 0.75)
}

function daylight_clock_string() {
    var _mins = floor(global.daylight_phase * 24 * 60)
    var _h = _mins div 60
    var _m = _mins mod 60
    return (_h < 10 ? "0" : "") + string(_h) + ":" + (_m < 10 ? "0" : "") + string(_m)
}
