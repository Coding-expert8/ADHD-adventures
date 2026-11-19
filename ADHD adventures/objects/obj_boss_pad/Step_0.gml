lit = beaten_count();
inside = false;
if (instance_exists(obj_player))
{
	var _dx = ((obj_player.bbox_left + obj_player.bbox_right) / 2 - x) / radius_x;
	var _dy = (obj_player.bbox_bottom - y) / radius_y;
	inside = (_dx * _dx + _dy * _dy <= 1);
}
show = clamp(show + (inside ? 0.1 : -0.1), 0, 1);

// all six: Q on the pad goes to the boss
if (inside and lit >= array_length(global.beaten_flags) and keyboard_check_pressed(ord("Q"))
	and !instance_exists(global.dialogue_npc) and !transition_active() and !typing_name() and !pause_menu_open())
{
	keyboard_clear(ord("Q"));
	global.return_x = obj_player.x;   // come back here after the boss
	global.return_y = obj_player.y;
	transition_to(boss_room);
}
