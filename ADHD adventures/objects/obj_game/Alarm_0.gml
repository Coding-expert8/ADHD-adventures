
if (choose(0, 1) == 0)
{
	var xx = choose((obj_player.x-683), (obj_player+683));
	var yy = irandom_range(0, room_height);
}
else
{
	var xx = irandom_range((obj_player.x-683), (obj_player+683));
	var yy = choose(0, room_height);
}
instance_create_layer(xx, yy, "Instances", obj_asteroid);
alarm[0] = 4 * 60

//choose((0), (room_width));
//irandom_range((0), (room_width));
//create wall object, check solid

var spd = 4;

// Horizontal movement
if (keyboard_check(vk_right)) {
    if (!place_meeting(x + spd, y, obj_wall)) {
        x += spd;
    }
}
if (keyboard_check(vk_left)) {
    if (!place_meeting(x - spd, y, obj_wall)) {
        x -= spd;
    }
}

// Vertical movement
if (keyboard_check(vk_up)) {
    if (!place_meeting(x, y - spd, obj_wall)) {
        y -= spd;
    }
}
if (keyboard_check(vk_down)) {
    if (!place_meeting(x, y + spd, obj_wall)) {
        y += spd;
    }
}
