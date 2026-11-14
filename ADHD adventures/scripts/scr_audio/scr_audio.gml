// Looping sound effects: ambience and footsteps, each running for exactly as
// long as the thing making it is happening.

// Default playback volume for sound effects and ambience.
#macro SFX_VOLUME 0.5

// How long ambience takes to fade in and out. Weather turns on and off in a
// single frame, so without a fade the rain would arrive and leave as a click.
#macro SFX_FADE_MS 700

// sound index -> the instance of it currently looping (noone = not running).
global.sfx_loops = {};

// Loops that have been faded out and are waiting to be stopped: {id, frames}.
// Fading a sound to silence does not stop it -- it keeps looping inaudibly and
// holding a voice -- so each one is stopped once its fade has had time to run.
global.sfx_fading = [];

/// @func sfx_loop_set(sound, on, [fade_ms], [volume])
/// @desc Keeps `sound` looping for exactly as long as `on` is true. Safe to call
///       every step from a Step event: it only starts or stops on a change.
///       Pass fade_ms 0 for sounds that should cut in and out cleanly.
function sfx_loop_set(_snd, _on, _fade_ms = SFX_FADE_MS, _vol = SFX_VOLUME) {
    var _key     = string(_snd);
    var _id      = global.sfx_loops[$ _key] ?? noone;
    var _playing = (_id != noone and audio_is_playing(_id));

    if (_on) {
        if (_playing) return;
        _id = audio_play_sound(_snd, 5, true);
        if (_fade_ms > 0) {
            audio_sound_gain(_id, 0, 0);          // start silent, then fade up
            audio_sound_gain(_id, _vol, _fade_ms);
        } else {
            audio_sound_gain(_id, _vol, 0);
        }
        global.sfx_loops[$ _key] = _id;
        return;
    }

    if (!_playing) return;
    global.sfx_loops[$ _key] = noone;

    if (_fade_ms <= 0) {
        audio_stop_sound(_id);
        return;
    }
    audio_sound_gain(_id, 0, _fade_ms);
    var _frames = ceil(_fade_ms * game_get_speed(gamespeed_fps) / 1000) + 2;
    array_push(global.sfx_fading, { id: _id, frames: _frames });
}

/// @func sfx_step()
/// @desc Stops ambience whose fade-out has finished. Run every step by
///       obj_weather_control. Nothing breaks in rooms without one: footsteps
///       use fade_ms 0 and so never queue a fade in the first place.
function sfx_step() {
    for (var _i = array_length(global.sfx_fading) - 1; _i >= 0; _i--) {
        var _f = global.sfx_fading[_i];
        _f.frames--;
        if (_f.frames <= 0) {
            if (audio_is_playing(_f.id)) audio_stop_sound(_f.id);
            array_delete(global.sfx_fading, _i, 1);
        }
    }
}
