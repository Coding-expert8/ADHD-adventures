var _ctrl = obj_fishing_control;
if (_ctrl.game_over) exit;

// Waiting: SPACE uses one bait and drops the hook
if (not falling) {
    if (keyboard_check_pressed(vk_space) and _ctrl.bait > 0) {
        falling = true;
		audio_play_sound(snd_splash_2, 3, false, 1, 0.1)
        _ctrl.bait -= 1;
    }
    exit;
}

y += fall_speed;

var _fish = instance_place(x, y, obj_fish);
if (_fish != noone) {
    // Caught something: score it (trash is negative, never below 0) and reset the hook
    _ctrl.fish_score = max(0, _ctrl.fish_score + _fish.points);
    if (_fish.points > 0) _ctrl.fish_caught += 1; // trash isn't a fish
    instance_destroy(_fish);
    falling = false;
    y = start_y;
}
else if (y > room_height) {
    // Missed: the bait is gone, the hook comes back
    falling = false;
    y = start_y;
}
