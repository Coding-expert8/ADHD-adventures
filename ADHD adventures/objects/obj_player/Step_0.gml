image_speed = 0

if keyboard_check(vk_right){
	image_xscale = 1
	x = x + (keyboard_check(vk_shift) ? 6 : 3)
}

if keyboard_check(vk_left){
	image_xscale = -1
	x = x - (keyboard_check(vk_shift) ? 6 : 3)
}

if keyboard_check(vk_up){
	y = y - (keyboard_check(vk_shift) ? 6 : 3)
}

if keyboard_check(vk_down){
	y = y + (keyboard_check(vk_shift) ? 6 : 3)
}


var _shift = keyboard_check(vk_shift)

if (keyboard_check(vk_up)){
	image_speed = 0.5
	sprite_index = spr_player_walk_up
} else if (keyboard_check(vk_down)){
	image_speed = 0.5
	sprite_index = spr_player_walk_down
} else if (keyboard_check(vk_right) || keyboard_check(vk_left)){
	image_speed = 0.5
	sprite_index = _shift ? spr_player_run : spr_player_walk
} else {
	sprite_index = spr_player_idle
}
