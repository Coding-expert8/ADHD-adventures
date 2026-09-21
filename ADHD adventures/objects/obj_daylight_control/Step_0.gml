var _rate = keyboard_check(DAYLIGHT_FAST_KEY) ? DAYLIGHT_FAST_SCALE : 1
global.daylight_phase = frac(global.daylight_phase + _rate / DAYLIGHT_CYCLE_FRAMES)
