if global.walking = "walk"
{
	image_speed = keyboard_check(vk_shift) ? 0.4 : 0.3
}
else 
{
	image_speed = 0.1
}
if (!variable_instance_exists(id, "facing")) facing = "down";

var _left  = keyboard_check(vk_left);
var _right = keyboard_check(vk_right);
_up    = keyboard_check_pressed(vk_up) or keyboard_check_pressed(vk_space);
var _down  = keyboard_check(vk_down);
var _spd   = keyboard_check(vk_shift) ? 6 : 4;


world_move((_right - _left) * _spd, (_down - _up) * _spd * 0);


global.walking = (_up or _down or _left or _right) ? "walk" : "idle";


if (_left)  facing = "left";
else if (_right) facing = "right";


sprite_index = character_sprites[$ global.character][$ global.walking][$ facing];


with (instance_place(x, y, par_trigger)) event_user(0);


_movingPlatform = instance_place(x, y + max(1,vspeed), obj_moving_platform);
if (_movingPlatform && bbox_bottom <= _movingPlatform.bbox_top) {
	if (vspeed > 0) {
		while (!place_meeting(x, y + sign(vspeed), obj_moving_platform)) {
			y += sign(vspeed);
		}
		vspeed = 0;
	}
	
}







_platform = instance_place(x, y + max(1,vspeed), obj_platform);

if (_platform && bbox_bottom-2 <= _platform.bbox_top)  and (_up)
{
	motion_set(image_angle + 90, jump);
	audio_play_sound(snd_jump,1,false);
}
else if (_platform) and sign(vspeed) = 1
{
	vspeed =  0;
	gravity = 0;

}
if instance_place(x, y-1, obj_platform) and bbox_bottom < _platform.bbox_top {
	y -= 1;
}

if  instance_place(x, y, obj_platform) and bbox_bottom > _platform.y-5 {
	y += 1;
}


if (!place_meeting(x,y,obj_moving_platform) and !(_platform && bbox_bottom > _platform.bbox_top))
{
	gravity = 0.3;
}


if keyboard_check_released(vk_space) or keyboard_check_released(vk_up) {
	jump_released = true;
}
else {
	jump_released = false;
}

if place_meeting(x,y,obj_platform) {
	if (_up) {
		motion_set(image_angle + 90, jump);
	}
	counter = 0;
	alarm[2] = 1;
}



