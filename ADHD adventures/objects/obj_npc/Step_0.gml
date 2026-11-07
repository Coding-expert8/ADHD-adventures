var _talking = (global.dialogue_npc == id);

// typewriter reveal
if (_talking) shown = min(shown + text_speed, string_length(dialogue[line]));

if (!keyboard_check_pressed(ord("Q"))) exit;

if (_talking)
{
	var _len = string_length(dialogue[line]);
	if (shown < _len)                               shown = _len;              // finish the line
	else if (line + 1 < array_length(dialogue))     { line += 1; shown = 0; }  // next line
	else                                            global.dialogue_npc = noone; // done
	keyboard_clear(ord("Q")); // consume the press so no other NPC reacts to it this step
}
else if (!instance_exists(global.dialogue_npc) and array_length(dialogue) > 0
	and instance_exists(obj_player) and distance_to_object(obj_player) <= talk_range)
{
	global.dialogue_npc = id;
	line  = 0;
	shown = 0;
	keyboard_clear(ord("Q"));
}
