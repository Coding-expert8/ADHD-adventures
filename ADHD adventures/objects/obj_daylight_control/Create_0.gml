// Plays the ten-minute day/night cycle over whatever the camera is looking at.
// The tint is drawn in Draw End, after every layer has had its turn -- including
// the weather particles at depth -10000 -- so rain and snow sit under the same
// sky as the ground does.

// Draw End events still run in depth order, and obj_world draws its F1 debug
// readout there too. Sitting at the very back of that queue means the tint goes
// down first and anything drawn late stays legible on top of it.
depth = 16000;

// Uniform handles are looked up once: shader_get_uniform is a string lookup and
// this runs every frame.
u_view     = shader_get_uniform(shd_daylight, "u_view");
u_phase    = shader_get_uniform(shd_daylight, "u_phase");
u_strength = shader_get_uniform(shd_daylight, "u_strength");
