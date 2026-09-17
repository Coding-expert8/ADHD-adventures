// World controller: place one on the "Instances" layer of every room the player walks around in.
// - Finds the "Collision" and "Terrain" tile layers and hides them (F1 shows collision).
// - Turns sprites on the "Props" asset layer into obj_prop instances.
// - Draws every par_ysort instance in order of its base, so things lower on screen are in front.

global.tm_collision = -1;
global.tm_terrain = -1;

var _collision_layer = layer_get_id("Collision");
if (_collision_layer != -1) {
    global.tm_collision = layer_tilemap_get_id(_collision_layer);
    layer_set_visible(_collision_layer, global.world_debug);
}

var _terrain_layer = layer_get_id("Terrain");
if (_terrain_layer != -1) {
    global.tm_terrain = layer_tilemap_get_id(_terrain_layer);
    layer_set_visible(_terrain_layer, false);
    instance_create_depth(0, 0, layer_get_depth(_terrain_layer) - 1, obj_terrain);
}

var _props_layer = layer_get_id("Props");
if (_props_layer != -1) {
    var _elements = layer_get_all_elements(_props_layer);
    for (var _i = 0; _i < array_length(_elements); _i++) {
        var _element = _elements[_i];
        if (layer_get_element_type(_element) != layerelementtype_sprite) continue;
        instance_create_layer(layer_sprite_get_x(_element), layer_sprite_get_y(_element), layer, obj_prop, {
            sprite_index: layer_sprite_get_sprite(_element),
            image_index: layer_sprite_get_index(_element),
            image_xscale: layer_sprite_get_xscale(_element),
            image_yscale: layer_sprite_get_yscale(_element),
            image_blend: layer_sprite_get_blend(_element),
        });
    }
    layer_destroy(_props_layer);
}

sort_list = ds_list_create();
sort_queue = ds_priority_create();
