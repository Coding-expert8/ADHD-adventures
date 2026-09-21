if (global.current_theme != noone and audio_is_playing(global.current_theme)) {
    audio_stop_sound(global.current_theme)
}
if (fade_snd != noone and audio_is_playing(fade_snd)) audio_stop_sound(fade_snd)
global.current_theme = noone
global.current_area  = noone
