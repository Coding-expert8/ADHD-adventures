draw_clear(c_black);

for (var yy = 0; yy < grid_h; yy++) {
    for (var xx = 0; xx < grid_w; xx++) {
        var spr = ((xx + yy) % 2 == 0) ? spr_bg_tile_light : spr_bg_tile_dark;
        draw_sprite(spr, 0, board_offset_x + xx*cell_size, yy*cell_size);
    }
}

draw_set_color(c_white);
draw_rectangle(board_offset_x, 0, board_offset_x + grid_w*cell_size - 1, grid_h*cell_size - 1, true);

draw_sprite_ext(fruit_sprite, fruit_frame, board_offset_x + fruit_x*cell_size + 32, fruit_y*cell_size + 32, 0.85, 0.85, 0, c_white, 1);

for (var i = 1; i < ds_list_size(grid_snake); i++) {
    var seg = grid_snake[| i];
    draw_sprite(spr_snake_body, 0, board_offset_x + seg.x*cell_size + 32, seg.y*cell_size + 32);
}

var head = grid_snake[| 0];
draw_sprite_ext(spr_snake_head, 0, board_offset_x + head.x*cell_size + 32, head.y*cell_size + 32, 1, 1, scr_dir_to_angle(direction_move) + head_angle_offset, c_white, 1);

draw_set_color(c_white);
draw_text(50, 20, "PLAYER");
draw_text(50, 60, "Score:");
draw_text(50, 80, string(score));
//if (active_powerup != "none") {
   // draw_text(panel_w/2 - 30, 120, "Power:");
   // draw_text(panel_w/2 - 30, 140, active_powerup);
  //  draw_text(panel_w/2 - 30, 160, string(powerup_timer div room_speed) + "s");
//}

//var right_x = board_offset_x + grid_w*cell_size;
//draw_set_color(c_white);
//draw_text(right_x + panel_w/2 - 30, 20, "OPPONENT");
//draw_text(right_x + panel_w/2 - 40, 60, "(coming soon)");