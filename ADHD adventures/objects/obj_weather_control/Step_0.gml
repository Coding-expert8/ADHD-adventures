// Each effect spawns across a padded box around the view (see weather_emit),
// so the weather travels with the player instead of being left behind.
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
