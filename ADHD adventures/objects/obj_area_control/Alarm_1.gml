// The outgoing theme has finished fading to silence -- stop it so it doesn't
// keep looping (inaudibly) and hogging an audio channel.
if (fade_snd != noone) {
    if (audio_is_playing(fade_snd)) audio_stop_sound(fade_snd);
    fade_snd = noone;
}
