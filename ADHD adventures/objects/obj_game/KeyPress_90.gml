
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
