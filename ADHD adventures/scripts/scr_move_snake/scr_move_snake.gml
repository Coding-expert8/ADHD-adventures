function scr_move_snake() {
    with (obj_game) {
        direction_move = next_direction;

        var head = grid_snake[| 0];
        var nx = head.x;
        var ny = head.y;

        switch (direction_move) {
            case "up":    ny -= 1; break;
            case "down":  ny += 1; break;
            case "left":  nx -= 1; break;
            case "right": nx += 1; break;
        }

        if (nx < 0 || nx >= grid_w || ny < 0 || ny >= grid_h) {
            game_over = true;
            exit;
        }

        if (active_powerup != "ghost") {
            for (var i = 0; i < ds_list_size(grid_snake); i++) {
                var seg = grid_snake[| i];
                if (seg.x == nx && seg.y == ny) {
                    game_over = true;
                    exit;
                }
            }
        }

        ds_list_insert(grid_snake, 0, {x: nx, y: ny});

        if (nx == fruit_x && ny == fruit_y) {
            scr_handle_fruit_eaten();
            scr_spawn_fruit();
        } else if (grow_pending > 0) {
            grow_pending -= 1;
        } else {
            ds_list_delete(grid_snake, ds_list_size(grid_snake) - 1);
        }
    }
}