// F1: toggle the debug view
global.world_debug = !global.world_debug;
var _collision_layer = layer_get_id("Collision");
if (_collision_layer != -1) layer_set_visible(_collision_layer, global.world_debug);
