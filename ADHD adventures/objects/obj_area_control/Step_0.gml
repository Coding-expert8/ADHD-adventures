if (!instance_exists(obj_player)) exit

var _area = instance_position(obj_player.x, obj_player.y, obj_area)

var _key = ""
if (_area != noone) {
    _key = (_area.area_name != "") ? _area.area_name : "#" + string(_area)
}
if (_key == global.current_area_key) exit

var _profile = (_area != noone) ? _area.area_profile : WEATHER_PROFILE_RAIN
global.weather_profile = _profile

if (!weather_allowed(global.weather, _profile)) global.weather = WEATHER_NONE

weather_roll()
with (obj_weather_control) alarm[0] = WEATHER_ROLL_FRAMES

var _theme = (_area != noone) ? _area.area_theme : noone
if (_theme != global.current_theme) {
    if (fade_snd != noone and audio_is_playing(fade_snd)) audio_stop_sound(fade_snd)
    fade_snd = noone

    if (global.current_theme != noone and audio_is_playing(global.current_theme)) {
        audio_sound_gain(global.current_theme, 0, FADE_MS)
        fade_snd = global.current_theme
        alarm[1] = 40
    }

    if (_theme != noone) {
        audio_play_sound(_theme, 10, true)
        audio_sound_gain(_theme, 0, 0)
        audio_sound_gain(_theme, 1, FADE_MS)
    }

    global.current_theme = _theme
}

global.current_area     = _area
global.current_area_key = _key
