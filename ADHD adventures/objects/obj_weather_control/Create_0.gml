alarm[0] = 60

// --- Rain ---------------------------------------------------------------
rain_dir     = 262;   // direction the drops fall (270 = straight down, less = blown left)
rain_density = 4;    // drops spawned per step
rain_splashes = 2;    // ground splashes spawned per step

rain_ps = part_system_create();
part_system_depth(rain_ps, -10000);   // in front of the world and its Y-sorted props

// A drop is a short streak leaning the way it falls.
rain_pt_drop = part_type_create();
part_type_shape(rain_pt_drop, pt_shape_line);
part_type_size(rain_pt_drop, 0.08, 0.14, 0, 0);
part_type_scale(rain_pt_drop, 1, 1.25);   // x = streak length, y = streak width
// pt_shape_line is drawn horizontally, so the streak points along rain_dir as-is.
part_type_orientation(rain_pt_drop, rain_dir, rain_dir, 0, 0, false);
part_type_colour2(rain_pt_drop, c_ltgrey, c_aqua);
part_type_alpha2(rain_pt_drop, 0.9, 0.55);
part_type_speed(rain_pt_drop, 16, 22, 0, 0);
part_type_direction(rain_pt_drop, rain_dir - 2, rain_dir + 2, 0, 0);
part_type_gravity(rain_pt_drop, 0.5, 270);
part_type_life(rain_pt_drop, 35, 55);

// Splashes are sprinkled over the visible ground rather than spawned where a
// drop dies -- drops outlive the fall, so their death point is mid-air.
rain_pt_splash = part_type_create();
part_type_shape(rain_pt_splash, pt_shape_disk);
part_type_size(rain_pt_splash, 0.04, 0.09, -0.004, 0);
part_type_colour2(rain_pt_splash, c_aqua, c_white);
part_type_alpha2(rain_pt_splash, 0.5, 0);
part_type_speed(rain_pt_splash, 0.6, 1.6, -0.06, 0);
part_type_direction(rain_pt_splash, 200, 340, 0, 0);
part_type_gravity(rain_pt_splash, 0.3, 270);
part_type_life(rain_pt_splash, 8, 14);

rain_em_drops    = part_emitter_create(rain_ps);
rain_em_splashes = part_emitter_create(rain_ps);
