grow = min(1, grow + 0.06);

// walk in: the player's feet inside the oval (not while talking, in a menu or already fading)
if (grow < 1 or target_room == noone or !instance_exists(obj_player)) exit;
if (instance_exists(global.dialogue_npc) or transition_active()) exit;

var _fx = (obj_player.bbox_left + obj_player.bbox_right) / 2;
var _fy = obj_player.bbox_bottom;
var _dx = (_fx - x) / radius_x;
var _dy = (_fy - y) / radius_y;
var _inside = (_dx * _dx + _dy * _dy <= 1);
if (!armed) { armed = !_inside; exit; }   // opened under the player: step out first
if (_inside)
{
	// obj_player puts the player back here on returning to room_map
	global.return_x = obj_player.x;
	global.return_y = obj_player.y;
	global.last_minigame_room = target_room;   // the NPC who sent us (see obj_npc boss message)
	if (target_room == room_space_rocks_help)
	{
		// ice rocks uses the built-in lives and score (default -1 lives counts as a loss). Its help
		// screen sets lives too; this also clears an old score.
		lives = 3;
		score = 0;
		global.can_fire = true;
	}
	transition_to(target_room);
}
