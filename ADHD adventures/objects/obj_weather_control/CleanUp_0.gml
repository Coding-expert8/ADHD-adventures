part_type_destroy(rain_pt_drop);
part_type_destroy(rain_pt_splash);
part_type_destroy(snow_pt_flake);
part_type_destroy(sand_pt_grain);
part_type_destroy(sand_pt_gust);

part_emitter_destroy(weather_ps, rain_em_drops);
part_emitter_destroy(weather_ps, rain_em_splashes);
part_emitter_destroy(weather_ps, snow_em_flakes);
part_emitter_destroy(weather_ps, sand_em_grains);
part_emitter_destroy(weather_ps, sand_em_gusts);

part_system_destroy(weather_ps);
