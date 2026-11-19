// back from the last of the six minigames: the NPC who sent the player there starts talking
// by itself, pointing them to the boss (obj_boss_pad)
if (global.boss_message_pending and target_room != noone and target_room == global.last_minigame_room
	and !instance_exists(global.dialogue_npc) and !transition_active() and instance_exists(obj_player))
{
	global.boss_message_pending = false;
	saved_dialogue = dialogue;
	dialogue = boss_lines;
	boss_talk = true;
	global.dialogue_npc = id;
	line  = 0;
	shown = 0;
}

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

	// a major NPC opens a portal to its minigame next to it once the talk is over;
	// the player walks into it to start (obj_minigame_portal)
	if (global.dialogue_npc == noone and boss_talk)
	{
		dialogue = saved_dialogue;   // the boss message is said once; back to the usual lines
		boss_talk = false;
	}
	else if (global.dialogue_npc == noone and target_room != noone) open_portal();
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

