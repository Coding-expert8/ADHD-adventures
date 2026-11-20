// remember the player's native scale once, so other rooms keep whatever it already is
if (!variable_instance_exists(id, "base_xscale")) {
	base_xscale = image_xscale
	base_yscale = image_yscale
}
if (!variable_instance_exists(id, "facing")) facing = "down";

// answer-block minigame rooms keep their own movement, sprites and falling logic
if room == room_answer
{
	image_speed = 0

	// new sprites have real left/right art, so no mirroring
	// only room_answer is shrunk (0.7 of the native size)
	var _mult = (room == room_answer) ? 0.7 : 1
	image_xscale = base_xscale * _mult
	image_yscale = base_yscale * _mult

	var _spd = 4
	if keyboard_check(vk_shift) {
		_spd = 12
	}

	// room_answer is side-on only, so never use up/down facing there
	if (room == room_answer and (facing == "up" or facing == "down")) facing = "right"

	if keyboard_check(vk_right) {
		facing = "right"
		x += _spd
	}
	if keyboard_check(vk_left) {
		facing = "left"
		x -= _spd
	}


	var _moving = keyboard_check(vk_right) or keyboard_check(vk_left)

	if (_moving) {
		// no run sprite in the new set, so shift just speeds up the walk cycle
		image_speed = keyboard_check(vk_shift) ? 1.5 : 1
		switch (facing) {
			case "up":    sprite_index = spr_char_1_walk_up;    break
			case "down":  sprite_index = spr_char_1_walk_down;  break
			case "left":  sprite_index = spr_char_1_walk_left;  break
			case "right": sprite_index = spr_char_1_walk_right; break
		}
	} else {
		switch (facing) {
			case "up":    sprite_index = spr_char_1_idle_up;    break
			case "down":  sprite_index = spr_char_1_idle_down;  break
			case "left":  sprite_index = spr_char_1_idle_left;  break
			case "right": sprite_index = spr_char_1_idle_right; break
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
		global.hearts -= 1
		room_goto(room_map)
		}
	}
	exit;
}

// every other room: back to the player's native scale
image_xscale = base_xscale
image_yscale = base_yscale

if global.walking = "walk"
{
	image_speed = keyboard_check(vk_shift) ? 0.4 : 0.3
}
else 
{
	image_speed = 0.1
}

// stand still while an NPC is talking (obj_npc handles the Q key), the name popup is open,
// or the PAUSE / CREDITS board is open
if (instance_exists(global.dialogue_npc) or (instance_exists(obj_login) and obj_login.popup_open) or pause_menu_open())
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

// Footsteps, fired off the walk animation rather than looped, so each one lands
// with a foot and keeps pace by itself when shift speeds the cycle up. A cycle
// plants a foot twice -- a quarter of the way in and three quarters -- and
// reading that as a fraction keeps it right whatever a character's frame count.
// Only fire on the frame the animation ARRIVES at a contact frame, or it would
// retrigger every step the animation sits on one.
if (global.walking == "walk")
{
	var _contact = floor(image_index);
	if (_contact != last_step_frame)
	{
		last_step_frame = _contact;
		var _cycle = sprite_get_number(sprite_index);
		if (_contact == floor(_cycle * 0.25) or _contact == floor(_cycle * 0.75))
		{
			audio_play_sound(snd_walk, 4, false, SFX_VOLUME);
		}
	}
}
else last_step_frame = -1;

// doors and other triggers under the player's feet
with (instance_place(x, y, par_trigger)) event_user(0);


// a key won in a minigame (minigame_win) appears next to the player, one at a time
if (room == room_map and global.keys_pending > 0 and !instance_exists(obj_key)) {
	instance_create_layer(x + 30, y, "Instances", obj_key);
}