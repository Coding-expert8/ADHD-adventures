part_type_destroy(rain_pt_drop);
part_type_destroy(rain_pt_splash);
part_emitter_destroy(rain_ps, rain_em_drops);
part_emitter_destroy(rain_ps, rain_em_splashes);
part_system_destroy(rain_ps);
