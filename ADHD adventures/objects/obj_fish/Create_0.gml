// obj_fishing_control sets points, sprite_index, hspeed, image_xscale and wave after creating each fish.
points = 1;

// Sine-wave swimming (only used when wave is true)
wave = false;
base_y = y;
wave_amplitude = 3;          // pixels up/down
wave_speed = 0.08;           // radians per step
wave_time = random(2 * pi);  // so wavy fish aren't all in sync
