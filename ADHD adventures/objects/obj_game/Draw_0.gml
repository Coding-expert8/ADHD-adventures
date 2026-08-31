/// Draw Event
draw_clear(c_white);

// checkerboard background — alternating tile sprites
for (var yy = 0; yy < grid_h; yy++) {
    for (var xx = 0; xx < grid_w; xx++) {
        var spr = ((xx + yy) % 2 == 0) ? spr_bg_tile_light : spr_bg_tile_dark;
        draw_sprite(spr, 0, xx*cell_size, yy*cell_size);
    }
}

// draw fruit
draw_sprite(fruit_sprite, fruit_frame, fruit_x*cell_size, fruit_y*cell_size);

// draw snake body (top-left origin, no rotation needed)
for (var i = 1; i < ds_list_size(grid_snake); i++) {
    var seg = grid_snake[| i];
    draw_sprite(spr_snake_body, 0, seg.x*cell_size, seg.y*cell_size);
}

// draw head, rotated to face current direction
var head = grid_snake[| 0];
var head_cx = head.x*cell_size + cell_size/2;
var head_cy = head.y*cell_size + cell_size/2;
draw_sprite_ext(spr_snake_head, 0, head_cx, head_cy, 1, 1, scr_dir_to_angle(direction_move), c_white, 1);
// HUD
draw_text(8, grid_h*cell_size + 4, "Score: " + string(score));
if (active_powerup != "none") {
    draw_text(150, grid_h*cell_size + 4, "Power: " + active_powerup + " (" + string(powerup_timer div room_speed) + "s)");
}