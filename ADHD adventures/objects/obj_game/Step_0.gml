/// Step Event
if (game_over) exit;

// handle input buffering (prevents reversing into self)
if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
    if (direction_move != "down") next_direction = "up";
}
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
    if (direction_move != "up") next_direction = "down";
}
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
    if (direction_move != "right") next_direction = "left";
}
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
    if (direction_move != "left") next_direction = "right";
}

// power-up timer countdown
if (powerup_timer > 0) {
    powerup_timer -= 1;
    if (powerup_timer <= 0) {
        active_powerup = "none";
        game_speed = base_speed; // reset speed if it was slow/fast
    }
}

// move timing — room_speed should be 60
var _speed_frames = room_speed / game_speed;
move_timer += 1;
if (move_timer >= _speed_frames) {
    move_timer = 0;
    scr_move_snake();
}
