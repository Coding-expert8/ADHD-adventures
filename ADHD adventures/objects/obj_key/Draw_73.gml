// "Q" hint over the pill while the player is close enough to pick it up.
// Drawn in Draw End so nothing drawn after the key covers it.
if (variable_global_exists("dialogue_npc") and instance_exists(global.dialogue_npc)) exit;
if (!instance_exists(obj_player) or distance_to_object(obj_player) > pickup_range) exit;

if (variable_global_exists("dialogue_font")) draw_set_font(global.dialogue_font);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text_transformed((bbox_left + bbox_right) / 2, bbox_top - 2 + sin(current_time / 200) * 2, "Q", 0.8, 0.8, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
