/// Draw Event
draw_clear(c_white);

// checkerboard background
for (var yy = 0; yy < grid_h; yy++) {
    for (var xx = 0; xx < grid_w; xx++) {
        var spr = ((xx + yy) % 2 == 0) ? spr_bg_tile_light : spr_bg_tile_dark;
        draw_sprite(spr, 0, xx*cell_size, yy*cell_size);
    }
}

// board border
draw_set_color(c_black);
draw_rectangle(grid_w*cell_size, grid_h*cell_size, grid_w*cell_size - 10, grid_h*cell_size - 0, false);


// fruit, scaled to fit inside a cell
var fruit_pad = 0.85;
var fruit_scale = (cell_size * fruit_pad) / sprite_get_width(fruit_sprite);
var fruit_cx = fruit_x*cell_size + cell_size/2;
var fruit_cy = fruit_y*cell_size + cell_size/2;
draw_sprite_ext(fruit_sprite, fruit_frame, fruit_cx, fruit_cy, fruit_scale, fruit_scale, 0, c_white, 1);

// snake body, scaled + centered per cell
var body_scale = cell_size / sprite_get_width(spr_snake_body);
for (var i = 1; i < ds_list_size(grid_snake); i++) {
    var seg = grid_snake[| i];
    var bx = seg.x*cell_size + cell_size/2;
    var by = seg.y*cell_size + cell_size/2;
    draw_sprite_ext(spr_snake_body, 0, bx, by, body_scale, body_scale, 0, c_white, 1);
}

// snake head, scaled + rotated
var head_scale = cell_size / sprite_get_width(spr_snake_head);
var head = grid_snake[| 0];
var head_cx = head.x*cell_size + cell_size/2;
var head_cy = head.y*cell_size + cell_size/2;
draw_sprite_ext(spr_snake_head, 0, head_cx, head_cy, head_scale, head_scale, scr_dir_to_angle(direction_move), c_white, 1);

// HUD
draw_set_color(c_black);
draw_text(8, grid_h*cell_size + 4, "Score: " + string(score));
if (active_powerup != "none") {
    draw_text(150, grid_h*cell_size + 4, "Power: " + active_powerup + " (" + string(powerup_timer div room_speed) + "s)");
}