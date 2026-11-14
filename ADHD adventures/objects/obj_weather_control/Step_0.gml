// The air's colour trails the area and the weather rather than snapping to them.
air_tint_step();

// Run down the guaranteed stretch of the current spell (see weather_roll).
weather_hold_step();

// Ambience: one loop per weather that has a sound, running only while it does.
// Both fade, so a shower starting or breaking up is not an audible click.
sfx_step();
sfx_loop_set(snd_rain,      global.weather == WEATHER_RAIN,      SFX_FADE_MS, WEATHER_RAIN_VOLUME);
sfx_loop_set(snd_sandstorm, global.weather == WEATHER_SANDSTORM, SFX_FADE_MS, WEATHER_SAND_VOLUME);

switch (global.weather) {

    case WEATHER_RAIN:
        weather_emit(weather_ps, rain_em_drops,    rain_pt_drop,   rain_density);
        weather_emit(weather_ps, rain_em_splashes, rain_pt_splash, rain_splashes);
        break;

    case WEATHER_SNOW:
        weather_emit(weather_ps, snow_em_flakes, snow_pt_flake, snow_density);
        break;

    case WEATHER_SANDSTORM:
        weather_emit(weather_ps, sand_em_grains, sand_pt_grain, sand_density);
        weather_emit(weather_ps, sand_em_gusts,  sand_pt_gust,  sand_gusts);
        break;

    // WEATHER_NONE (and anything unrecognised) emits nothing; whatever is
    // already in the air finishes its life and the screen clears itself.
}
