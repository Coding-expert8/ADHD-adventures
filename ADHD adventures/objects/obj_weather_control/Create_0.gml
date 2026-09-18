alarm[0] = 60

// Every effect shares one system; only the emitters for global.weather fire.
weather_ps = part_system_create();
part_system_depth(weather_ps, -10000);   // in front of the world and its Y-sorted props

// --- Rain ---------------------------------------------------------------
rain_dir      = 262;  // direction the drops fall (270 = straight down, less = blown left)
rain_density  = 4;    // drops spawned per step
rain_splashes = 2;    // ground splashes spawned per step

// A drop is a short streak leaning the way it falls.
rain_pt_drop = part_type_create();
part_type_shape(rain_pt_drop, pt_shape_line);
part_type_size(rain_pt_drop, 0.08, 0.14, 0, 0);
part_type_scale(rain_pt_drop, 1, 1.25);   // x = streak length, y = streak width
// pt_shape_line is drawn horizontally, so the streak points along rain_dir as-is.
part_type_orientation(rain_pt_drop, rain_dir, rain_dir, 0, 0, false);
part_type_colour2(rain_pt_drop, c_ltgray, c_blue);
part_type_alpha2(rain_pt_drop, 0.8, 0.6);
part_type_speed(rain_pt_drop, 16, 22, 0, 0);
part_type_direction(rain_pt_drop, rain_dir - 2, rain_dir + 2, 0, 0);
part_type_gravity(rain_pt_drop, 0.4, 270);
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

rain_em_drops    = part_emitter_create(weather_ps);
rain_em_splashes = part_emitter_create(weather_ps);

// --- Snow ---------------------------------------------------------------
snow_dir     = 268;   // flakes drift almost straight down
snow_density = 2;     // flakes spawned per step -- they live a long time, so a
                      // trickle is enough to keep the screen filled

// Flakes fall slowly and wander: the wiggle on direction makes each one flutter
// sideways instead of dropping on rails.
snow_pt_flake = part_type_create();
part_type_shape(snow_pt_flake, pt_shape_snow);
part_type_size(snow_pt_flake, 0.04, 0.09, 0, 0);
part_type_colour2(snow_pt_flake, c_white, make_colour_rgb(200, 226, 255));
part_type_alpha3(snow_pt_flake, 0, 0.9, 0.7);   // fade in so flakes don't pop into view
part_type_speed(snow_pt_flake, 1.6, 3, 0, 0);
part_type_direction(snow_pt_flake, snow_dir - 6, snow_dir + 6, 0, 12);
part_type_orientation(snow_pt_flake, 0, 359, 1.5, 0, false);
part_type_life(snow_pt_flake, 200, 280);

snow_em_flakes = part_emitter_create(weather_ps);

// --- Sandstorm ----------------------------------------------------------
sand_dir      = 190;  // wind direction (180 = dead sideways to the left)
sand_density  = 1;   // grains spawned per step
sand_gusts    = 1;    // haze clouds spawned per step

// Grains: tiny dashes stretched along the wind, moving fast enough to read as
// a blur rather than as individual specks.
sand_pt_grain = part_type_create();
part_type_shape(sand_pt_grain, pt_shape_pixel);
part_type_size(sand_pt_grain, 0.6, 1.4, 0, 0);
part_type_scale(sand_pt_grain, 4, 1);
part_type_orientation(sand_pt_grain, sand_dir, sand_dir, 0, 0, false);
part_type_colour2(sand_pt_grain, make_colour_rgb(222, 196, 140), make_colour_rgb(176, 137, 90));
part_type_alpha3(sand_pt_grain, 0, 0.75, 0);
part_type_speed(sand_pt_grain, 18, 30, 0, 0);
part_type_direction(sand_pt_grain, sand_dir - 5, sand_dir + 5, 0, 3);
part_type_life(sand_pt_grain, 40, 70);

// Gusts: big soft clouds at low alpha that wash the screen sand-coloured and
// hide the fact that the grains are only a few dozen pixels apart.
sand_pt_gust = part_type_create();
part_type_shape(sand_pt_gust, pt_shape_cloud);
part_type_size(sand_pt_gust, 1.5, 3, 0.01, 0);
part_type_colour2(sand_pt_gust, make_colour_rgb(214, 184, 126), make_colour_rgb(190, 158, 104));
part_type_alpha3(sand_pt_gust, 0, 0.22, 0);
part_type_speed(sand_pt_gust, 8, 14, 0, 0);
part_type_direction(sand_pt_gust, sand_dir - 8, sand_dir + 8, 0, 0);
part_type_life(sand_pt_gust, 70, 110);

sand_em_grains = part_emitter_create(weather_ps);
sand_em_gusts  = part_emitter_create(weather_ps);
