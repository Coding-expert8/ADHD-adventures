/// Draw Event
draw_clear(c_black);

// checkerboard background — offset right to leave room for the left panel
for (var yy = 0; yy < grid_h; yy++) {
    for (var xx = 0; xx < grid_w; xx++) {
        var spr = ((xx + yy) % 2 == 0) ? spr_bg_tile_light : spr_bg_tile_dark;
        draw_sprite(spr, 0, board_offset_x + xx*cell_size, yy*cell_size);
    }
}

// board border
draw_set_color(c_white);
draw_rectangle(board_offset_x, 0, board_offset_x + grid_w*cell_size - 1, grid_h*cell_size - 1, true);
draw_rectangle(board_offset_x + 1, 1, board_offset_x + grid_w*cell_size - 2, grid_h*cell_size - 2, true);

// fruit, scaled to fit inside a cell
var fruit_pad = 0.85;
var fruit_scale = (cell_size * fruit_pad) / sprite_get_width(fruit_sprite);
var fruit_cx = board_offset_x + fruit_x*cell_size + cell_size/2;
var fruit_cy = fruit_y*cell_size + cell_size/2;
draw_sprite_ext(fruit_sprite, fruit_frame, fruit_cx, fruit_cy, fruit_scale, fruit_scale, 0, c_white, 1);

// snake body, scaled + centered per cell
var body_scale = cell_size / sprite_get_width(spr_snake_body);
for (var i = 1; i < ds_list_size(grid_snake); i++) {
    var seg = grid_snake[| i];
    var bx = board_offset_x + seg.x*cell_size + cell_size/2;
    var by = seg.y*cell_size + cell_size/2;
    draw_sprite_ext(spr_snake_body, 0, bx, by, body_scale, body_scale, 0, c_white, 1);
}

// snake head, scaled + rotated
var head_scale = cell_size / sprite_get_width(spr_snake_head);
var head = grid_snake[| 0];
var head_cx = board_offset_x + head.x*cell_size + cell_size/2;
var head_cy = head.y*cell_size + cell_size/2;
draw_sprite_ext(spr_snake_head, 0, head_cx, head_cy, head_scale, head_scale, scr_dir_to_angle(direction_move) + head_angle_offset, c_white, 1);

// left panel — player
draw_set_color(c_white);
draw_text(panel_w/2 - 24, 20, "PLAYER");
draw_text(panel_w/2 - 20, 60, "Score:");
draw_text(panel_w/2 - 10, 80, string(score));
if (active_powerup != "none") {
    draw_text(panel_w/2 - 30, 120, "Power:");
    draw_text(panel_w/2 - 30, 140, active_powerup);
    draw_text(panel_w/2 - 30, 160, string(powerup_timer div room_speed) + "s");
}

// right panel — opponent (placeholder only, no logic yet)
var right_x = board_offset_x + grid_w*cell_size;
draw_set_color(c_white);
draw_text(right_x + panel_w/2 - 30, 20, "OPPONENT");
draw_text(right_x + panel_w/2 - 40, 60, "(coming soon)");