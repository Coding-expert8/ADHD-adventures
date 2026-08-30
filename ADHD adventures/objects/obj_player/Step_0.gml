<<<<<<< HEAD
/// @description Insert description here
// You can write your code in this editor

if (keyboard_check(vk_left))
{
image_angle = image_angle + 5;
}


if (keyboard_check(vk_right))
{
image_angle = image_angle - 5;
}

if (keyboard_check(vk_up))
{
motion_add(image_angle, 0.05);
}


if (keyboard_check_pressed(vk_space))
{
	var inst = instance_create_layer(x, y, "Instances", obj_bullet);
	inst.direction = image_angle;
}






=======
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
>>>>>>> main
