if (opened)
{
	if (anim >= 0) anim += 1;
	if (anim == open_at) { image_index = 1; audio_play_sound(ding_sound_effect_1, 1, false); }
	exit;
}

near = false;
if (!instance_exists(obj_player)) exit;
var _fx = (obj_player.bbox_left + obj_player.bbox_right) / 2;
var _fy = obj_player.bbox_bottom;
near = (point_distance(_fx, _fy, x, y) <= talk_range);

if (near and keyboard_check_pressed(ord("Q"))
	and !instance_exists(global.dialogue_npc) and !transition_active() and !typing_name() and !pause_menu_open())
{
	keyboard_clear(ord("Q"));      // so an NPC nearby doesn't also start talking
	coins = choose(10, 50, 100);
	global.coin += coins;
	global.chests_opened[$ chest_id] = true;
	opened  = true;
	image_index = 0;
	anim = 0;
	audio_play_sound(snd_power_up, 1, false);
	save_game();
}
