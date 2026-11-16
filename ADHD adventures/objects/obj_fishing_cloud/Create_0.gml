// A sky cloud with a random size, height, speed and transparency.
// obj_fishing_control spawns these off the left edge every few seconds.
depth = 50; // in front of the backdrop (100), behind the hook and fish (0)

var _scale = random_range(0.5, 1.3);
image_xscale = _scale;
image_yscale = _scale * random_range(0.8, 1.1);
image_alpha = random_range(0.7, 1);
y = irandom_range(-12, 40);
hspeed = random_range(0.15, 0.5);
