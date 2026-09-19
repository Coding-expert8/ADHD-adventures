// Find the area the player is standing in (noone = open world), and react only
// when it changes. Polling the player's position is what lets us also notice
// leaving every area -- the par_trigger loop can only tell us about entering one.
//
// instance_position (not instance_place): instance_place tests the CALLING
// instance's mask, and this controller has no sprite, so it would never hit
// anything. instance_position tests the point against obj_area's own mask.
if (!instance_exists(obj_player)) exit;

var _area = instance_position(obj_player.x, obj_player.y, obj_area);
if (_area == global.current_area) exit;

// --- weather: open world allows rain; otherwise take the area's profile -------
var _profile = (_area != noone) ? _area.area_profile : WEATHER_PROFILE_RAIN;
global.weather_profile = _profile;

// Stop weather the new area forbids so it doesn't linger across the boundary.
if (!weather_allowed(global.weather, _profile)) global.weather = WEATHER_NONE;

// Give the new area an immediate chance at its own weather, then restart the
// timer so the next roll is a full interval away.
weather_roll();
with (obj_weather_control) alarm[0] = WEATHER_ROLL_FRAMES;

// --- music: swap themes, fading the old one out and the new one in ------------
var _theme = (_area != noone) ? _area.area_theme : noone;
if (_theme != global.current_theme) {
    // Fade out whatever is playing. Clear any earlier still-fading track first
    // so at most one theme is ever fading at a time.
    if (fade_snd != noone and audio_is_playing(fade_snd)) audio_stop_sound(fade_snd);
    fade_snd = noone;

    if (global.current_theme != noone and audio_is_playing(global.current_theme)) {
        audio_sound_gain(global.current_theme, 0, FADE_MS);
        fade_snd = global.current_theme;
        alarm[1] = 40; // stop the faded-out track once it's silent
    }

    // Fade the new theme in (theme-less areas and the open world play nothing).
    if (_theme != noone) {
        audio_play_sound(_theme, 10, true); // looping
        audio_sound_gain(_theme, 0, 0);
        audio_sound_gain(_theme, 1, FADE_MS);
    }

    global.current_theme = _theme;
}

global.current_area = _area;
