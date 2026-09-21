if (fade_snd != noone) {
    if (audio_is_playing(fade_snd)) audio_stop_sound(fade_snd)
    fade_snd = noone
}
