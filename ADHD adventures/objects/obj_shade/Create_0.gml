// A patch of ground that sits in shade: the foot of a cliff, under a bridge, the
// inside of a doorway. Drop one on the "Instances" layer of room_map and stretch
// it over the ground it should darken. Its sprite is the 32x32 spr_trigger box
// with its origin at the top left, so the room editor's handles size it in 32px
// steps and x,y is its top-left corner. It is never drawn and never solid -- the
// box is only there to be dragged.
//
// Per-instance creation code overrides any of these, the same way obj_area takes
// its name and profile:
//     shade_cover   = 0.35;        // deeper shade than the default
//     shade_feather = 16;          // a harder edge (a doorway, not a cliff)
//     shade_colour  = c_black;     // a different colour of dark
if (!variable_instance_exists(id, "shade_cover"))   shade_cover   = SHADE_COVER;
if (!variable_instance_exists(id, "shade_feather")) shade_feather = SHADE_FEATHER;
if (!variable_instance_exists(id, "shade_colour"))  shade_colour  = SHADE_COLOUR;

// Uniform handles are looked up once: shader_get_uniform is a string lookup and
// the draw runs every frame.
u_rect    = shader_get_uniform(shd_shade, "u_rect");
u_colour  = shader_get_uniform(shd_shade, "u_colour");
u_feather = shader_get_uniform(shd_shade, "u_feather");

// Drawn in Draw End, which runs in depth order: obj_daylight_control sits at
// 16000 so the day/night tint goes down first, and the lamps sit at the Instances
// layer depth of 300 so they come after. Landing between the two is the whole
// point -- shade deepens the daylight, and a lamp standing in it still lights it.
depth = 8000;
