// The NPC itself is drawn by obj_world in Y order (obj_npc is a par_ysort child).
// The star and the "Q" hint are drawn here, in Draw End, so props in front of the NPC never cover them.
var _cx = (bbox_left + bbox_right) / 2;

// Major NPCs (they start a minigame): a star in the minigame's colour floats above the head,
// above where the "Q" hint shows, with a soft pulsing glow behind it
if (target_room != noone)
{
	var _sy = bbox_top - 40 +sin(current_time / 300) * 3;
	draw_set_alpha(0.25 + 0.1 * sin(current_time / 250));
	draw_set_colour(star_colour);
	draw_circle(_cx, _sy, 12, false);
	draw_set_alpha(1);
	draw_star(_cx, _sy, 9, star_colour, merge_colour(star_colour, c_black, 0.55));
}

if (instance_exists(global.dialogue_npc) or array_length(dialogue) == 0) exit;
if (!instance_exists(obj_player) or distance_to_object(obj_player) > talk_range) exit;

draw_set_font(global.dialogue_font);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text_transformed(_cx, bbox_top - 2 + sin(current_time / 200) * 2, "Q", 0.8, 0.8, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
