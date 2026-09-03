/// scr_handle_fruit_eaten()
with (obj_game) {
    var pts = (active_powerup == "double_score") ? 20 : 10;

    switch (fruit_type) {
        case "normal":
            score += pts;
            grow_pending += 1;
            break;

        case "slow":
            score += pts;
            grow_pending += 1;
            active_powerup = "slow";
            game_speed = base_speed - 3; // slower
            powerup_timer = room_speed * 6; // 6 seconds
            break;

        case "fast":
            score += pts;
            grow_pending += 1;
            active_powerup = "fast";
            game_speed = base_speed + 4; // faster (higher risk/reward)
            powerup_timer = room_speed * 6;
            break;

        case "double_score":
            score += pts;
            grow_pending += 1;
            active_powerup = "double_score";
            powerup_timer = room_speed * 8;
            break;

        case "shrink":
            score += pts;
            // remove up to 2 segments but never go below length 1
            repeat(2) {
                if (ds_list_size(grid_snake) > 1) {
                    ds_list_delete(grid_snake, ds_list_size(grid_snake) - 1);
                }
            }
            break;

        case "ghost":
            score += pts;
            grow_pending += 1;
            active_powerup = "ghost"; // pass through own body temporarily
            powerup_timer = room_speed * 5;
            break;
    }
}