var _ctrl = obj_fishing_control;
if (_ctrl.game_over) exit;

// Waiting: SPACE uses one bait and drops the hook
if (not falling) {
    if (keyboard_check_pressed(vk_space) and _ctrl.bait > 0) {
        falling = true;
        _ctrl.bait -= 1;
    }
    exit;
}

y += fall_speed;

var _fish = instance_place(x, y, obj_fish);
if (_fish != noone) {
    // Caught one: score it and reset the hook
    _ctrl.fish_score += _fish.points;
    _ctrl.fish_caught += 1;
    instance_destroy(_fish);
    falling = false;
    y = start_y;
}
else if (y > room_height) {
    // Missed: the bait is gone, the hook comes back
    falling = false;
    y = start_y;
}
