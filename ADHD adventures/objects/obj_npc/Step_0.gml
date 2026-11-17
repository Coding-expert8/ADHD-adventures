var _talking = (global.dialogue_npc == id);

// typewriter reveal
if (_talking) shown = min(shown + text_speed, string_length(dialogue[line]));

// talking sound: loops only while letters are still appearing, cut off (no fade) once the line is out
if (_talking or global.dialogue_npc == noone)
{
	sfx_loop_set(snd_npc_talk, _talking and shown < string_length(dialogue[line]), 0, 1.2);
}

if (!keyboard_check_pressed(ord("Q"))) exit;

if (_talking)
{
	var _len = string_length(dialogue[line]);
	if (shown < _len)                               shown = _len;              // finish the line
	else if (line + 1 < array_length(dialogue))     { line += 1; shown = 0; }  // next line
	else                                            global.dialogue_npc = noone; // done
	keyboard_clear(ord("Q")); // consume the press so no other NPC reacts to it this step

	// a major NPC sends the player into its minigame once the talk is over
	if (global.dialogue_npc == noone and target_room != noone)
	{
		// obj_player puts the player back here on returning to room_map
		global.return_x = obj_player.x;
		global.return_y = obj_player.y;
		room_goto(target_room);
	}
}
else if (!instance_exists(global.dialogue_npc) and array_length(dialogue) > 0
	and !(instance_exists(obj_login) and obj_login.popup_open) // Q is just a letter while typing a name
	and instance_exists(obj_player) and distance_to_object(obj_player) <= talk_range)
{
	global.dialogue_npc = id;
	line  = 0;
	shown = 0;
	keyboard_clear(ord("Q"));
}

