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
	} else if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
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
	if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
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
	if (_below_block && _below_block.is_landed) {
		_on_block = true
	}

	var _on_rock = false
	if (_below_rock != noone) {
		_on_rock = true
	}

	if (!_on_block && !_on_rock) {
		is_dead = true
	}
}
if (is_dead) {
	if y < room_height-50
	y += 4
	else {
	global.spacing = 0
	ds_list_clear(global.block_order)
	global.collapse_chunk_size = 4
	room_goto(room_main)
	}
}