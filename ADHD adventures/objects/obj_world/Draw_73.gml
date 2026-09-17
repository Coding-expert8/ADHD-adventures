// Debug view (F1): footprints of sorted instances, triggers and spawn points.
if (!global.world_debug) exit;

draw_set_colour(c_yellow);
for (var _i = 0; _i < ds_list_size(sort_list); _i++) {
    with (sort_list[| _i]) draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
}
draw_set_colour(c_aqua);
with (par_trigger) draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
with (obj_spawn) draw_circle(x, y, 6, true);
draw_set_colour(c_white);
