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