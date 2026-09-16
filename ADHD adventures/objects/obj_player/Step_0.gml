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
var _up    = keyboard_check(vk_up);
var _down  = keyboard_check(vk_down);
var _spd   = keyboard_check(vk_shift) ? 6 : 4;

// movement: one pixel at a time per axis, so the player stops flush against anything solid
var _dx = (_right - _left) * _spd;
var _dy = (_down - _up) * _spd;
repeat (abs(_dx)) { if (world_blocked(x + sign(_dx), y)) break; x += sign(_dx); }
repeat (abs(_dy)) { if (world_blocked(x, y + sign(_dy))) break; y += sign(_dy); }

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