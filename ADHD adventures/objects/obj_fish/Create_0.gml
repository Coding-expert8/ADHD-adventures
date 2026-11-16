// obj_fishing_control sets points, sprite_index, hspeed, image_xscale, wave and spin after creating each fish.
points = 1;

// Sine-wave swimming (only used when wave is true)
wave = false;
base_y = y;
wave_amplitude = irandom_range(3, 5);          // pixels up/down
wave_speed = choose(0.07, 0.08, 0.1, 0.13);           // radians per step
wave_time = random(2 * pi);  // so wavy fish aren't all in sync

// Spinning (degrees per step, used by trash)
spin = 0;
