if (game_over) {
    if (keyboard_check_pressed(ord("R"))) room_restart();
    exit;
}

// Spawn a fish every so often
spawn_timer -= 1;
if (spawn_timer <= 0) {
    spawn_timer = irandom_range(30, 60);

    // Pick a fish type using the spawn chances
    var _roll = random(100);
    var _type = 0;
    while (_type < 4 and _roll >= fish_weight[_type]) {
        _roll -= fish_weight[_type];
        _type += 1;
    }

    // Start just off the left or right edge and swim across
    var _from_left = choose(true, false);
    var _fish = instance_create_layer(_from_left ? -40 : room_width + 40, irandom_range(fish_y_min[_type], fish_y_max[_type]), "Instances", obj_fish);
    _fish.points = fish_points[_type];
    _fish.sprite_index = fish_sprite[_type];
    _fish.hspeed = _from_left ? fish_speed[_type] : -fish_speed[_type];
    _fish.image_xscale = _from_left ? 1 : -1; // sprites face right
}

// Win: reached the goal
if (fish_score >= goal) {
    game_over = true;
    won = true;
    time_taken = (current_time - start_time) / 1000;
}
// Lose: out of bait and the last cast is done
else if (bait <= 0 and not obj_fishing_hook.falling) {
    game_over = true;
    time_taken = (current_time - start_time) / 1000;
}
