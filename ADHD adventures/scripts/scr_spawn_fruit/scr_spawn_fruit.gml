function scr_spawn_fruit() {
    with (obj_game) {
        var valid = false;
        var tries = 0;

        while (!valid && tries < 200) {
            fruit_x = irandom(grid_w - 1);
            fruit_y = irandom(grid_h - 1);
            valid = true;
            for (var i = 0; i < ds_list_size(grid_snake); i++) {
                var seg = grid_snake[| i];
                if (seg.x == fruit_x && seg.y == fruit_y) {
                    valid = false;
                    break;
                }
            }
            tries += 1;
        }

        if (irandom(3) == 0) {
            fruit_type = choose("slow", "fast", "double_score", "shrink", "ghost");
            fruit_sprite = spr_fruit_power;
            fruit_frame = scr_power_type_to_frame(fruit_type);
        } else {
            fruit_type = "normal";
            fruit_sprite = spr_fruit_normal;
            fruit_frame = 0;
        }
    }
}