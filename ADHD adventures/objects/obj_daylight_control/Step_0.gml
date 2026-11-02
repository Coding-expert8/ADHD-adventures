// Walk the clock forward. One step per frame over DAYLIGHT_CYCLE_FRAMES makes a
// whole day take ten minutes; frac() rolls midnight back to the start of the day.
// Holding D winds it on at DAYLIGHT_FAST_SCALE speed.
var _rate = keyboard_check(DAYLIGHT_FAST_KEY) ? DAYLIGHT_FAST_SCALE : 1;
global.daylight_phase = frac(global.daylight_phase + _rate / DAYLIGHT_CYCLE_FRAMES);
