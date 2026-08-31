image_speed = 0

if keyboard_check(vk_right){
	image_xscale = 1
	x = x + (keyboard_check(vk_shift) ? 12 : 4)
}

if keyboard_check(vk_left){
	image_xscale = -1
	x = x - (keyboard_check(vk_shift) ? 12 : 4)
}

if keyboard_check(vk_up){
	y = y - (keyboard_check(vk_shift) ? 12 : 4)
}

if keyboard_check(vk_down){
	y = y + (keyboard_check(vk_shift) ? 12 : 4)
}


var _shift = keyboard_check(vk_shift)

if (keyboard_check(vk_up)){
	image_speed = 1
	sprite_index = spr_player_walk_up
} else if (keyboard_check(vk_down)){
	image_speed = 1
	sprite_index = spr_player_walk_down
} else if (keyboard_check(vk_right) || keyboard_check(vk_left)){
	image_speed = 1
	sprite_index = _shift ? spr_player_run : spr_player_walk
} else {
	sprite_index = spr_player_idle
}

if room = room_answer  {
	if keyboard_check(vk_right){
	image_xscale = 1
	x = x + 5
}

if keyboard_check(vk_left){
	image_xscale = -1
	x = x-5
}
}
room_goto(room_snake)	