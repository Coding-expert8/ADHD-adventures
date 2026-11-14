// Footsteps, read at the top so this runs in every room: the minigame rooms
// below exit early and do not maintain global.walking, so they stay silent on
// foot rather than looping whatever the overworld left set. Taking last frame's
// value costs a frame of latency, which is inaudible on a 0.6s step loop.
// No fade -- footsteps should cut in and out with the feet.
sfx_loop_set(snd_walk, global.walking == "walk" and room != room_main and room != room_answer, 0);

// answer-block minigame rooms keep their own movement, sprites and falling logic
if (room == room_main or room == room_answer)
{
	image_speed = 0

	var _spd = 4
	if keyboard_check(vk_shift) {
		_spd = 12
	}

	if keyboard_check(vk_right) {
		image_xscale = 1
		x += _spd
	}
	if keyboard_check(vk_left) {
		image_xscale = -1
		x -= _spd
	}

	if (room == room_main) {
		if keyboard_check(vk_up) {
			y -= _spd
		}
		if keyboard_check(vk_down) {
			y += _spd
		}
	}

	if (room == room_main) {
		if (keyboard_check(vk_up)) {
			image_speed = 1
			sprite_index = spr_player_walk_up
		} else if (keyboard_check(vk_down)) {
			image_speed = 1
			sprite_index = spr_player_walk_down
		} else if (keyboard_check(vk_right) or keyboard_check(vk_left)) {
			image_speed = 1
			if keyboard_check(vk_shift) {
				sprite_index = spr_player_run
			} else {
				sprite_index = spr_player_walk
			}
		} else {
			sprite_index = spr_player_idle
		}
	}

	if room == room_answer {
		if (keyboard_check(vk_right) or keyboard_check(vk_left)) {
			image_speed = 1
			if keyboard_check(vk_shift) {
				sprite_index = spr_player_run
			} else {
				sprite_index = spr_player_walk
			}
		} else {
			sprite_index = spr_player_idle
		}
	}

	if (room == room_answer) {
		var _below_block = instance_place(x, y + 20, obj_block)
		var _below_rock = instance_place(x, y + 20, obj_rock)

		var _on_block = false
		if (_below_block and _below_block.is_landed) {
			_on_block = true
		}

		var _on_rock = false
		if (_below_rock != noone) {
			_on_rock = true
		}

		if (!_on_block and !_on_rock) {
			is_dead = true
		}
		else
		is_dead = false
	}
	if (floating_up) {
		y -= 3
		if (y <= float_target_y) {
			y = float_target_y
			floating_up = false
		}
	}
	if (is_dead and !floating_up) {
		if y < room_height-50
		y += 4
		else {
		global.spacing = 0
		ds_list_clear(global.block_order)
		global.collapse_chunk_size = 4
		room_goto(room_main)
		}
	}
	exit;
}

if global.walking = "walk"
{
	image_speed = keyboard_check(vk_shift) ? 0.4 : 0.3
}
else 
{
	image_speed = 0.1
}
if (!variable_instance_exists(id, "facing")) facing = "down";

// stand still while an NPC is talking (obj_npc handles the Q key)
if (instance_exists(global.dialogue_npc))
{
	global.walking = "idle";
	image_speed = 0.1;
	sprite_index = character_sprites[$ global.character][$ global.walking][$ facing];
	exit;
}

var _left  = keyboard_check(vk_left);
var _right = keyboard_check(vk_right);
var _up    = keyboard_check(vk_up);
var _down  = keyboard_check(vk_down);
var _spd   = keyboard_check(vk_shift) ? 6 : 4;

// movement: stops flush against solids and slides along slopes (bridge arches, diagonal walls)
world_move((_right - _left) * _spd, (_down - _up) * _spd);

// state: walk if ANY arrow key is held, otherwise idle
global.walking = (_up or _down or _left or _right) ? "walk" : "idle";

// facing: update only while a direction is held (keeps last facing when idle)
if (_up)         facing = "up";
else if (_down)  facing = "down";
else if (_left)  facing = "left";
else if (_right) facing = "right";

sprite_index = character_sprites[$ global.character][$ global.walking][$ facing];

// doors and other triggers under the player's feet
with (instance_place(x, y, par_trigger)) event_user(0);
