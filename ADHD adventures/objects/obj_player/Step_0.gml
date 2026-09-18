image_speed = 0
var _shift = keyboard_check(vk_shift)
var _spd = _shift ? 12 : 4

// --- Horizontal movement (all rooms) ---
if keyboard_check(vk_right) {
	image_xscale = 1
	x += _spd
}
if keyboard_check(vk_left) {
	image_xscale = -1
	x -= _spd
}

// --- Vertical movement (top-down room only) ---
if (room == room_main) {
	if keyboard_check(vk_up) {
		y -= _spd
	}
	if keyboard_check(vk_down) {
		y += _spd
	}
}

// --- Sprite selection ---
if (room == room_main) {
	if (keyboard_check(vk_up)) {
		image_speed = 1
		sprite_index = spr_player_walk_up
	} else if (keyboard_check(vk_down)) {
		image_speed = 1
		sprite_index = spr_player_walk_down
	} else if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
		image_speed = 1
		sprite_index = _shift ? spr_player_run : spr_player_walk
	} else {
		sprite_index = spr_player_idle
	}
} if room = room_answer {
	if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
		image_speed = 1
		sprite_index = _shift ? spr_player_run : spr_player_walk
	} else {
		sprite_index = spr_player_idle
	}
}
if (room == room_answer) {
	var _below = instance_place(x, y + 20, obj_block)
	
	if (!_below || !_below.is_landed) {
		is_dead = true
	}
}

if (is_dead) {
	y = y+10
}