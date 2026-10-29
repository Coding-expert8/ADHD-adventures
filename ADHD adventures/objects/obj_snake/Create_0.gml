grid_w = 8;
grid_h = 8;
cell_size = 64;

panel_w = 160;
board_offset_x = panel_w;
head_angle_offset = 180;

game_speed = 5;
base_speed = 5;
move_timer = 0;

score = 0;
game_over = false;

active_powerup = "none";
powerup_timer = 0;

sprite_set_offset(spr_snake_head, sprite_get_width(spr_snake_head)/2, sprite_get_height(spr_snake_head)/2);
sprite_set_offset(spr_snake_body, sprite_get_width(spr_snake_body)/2, sprite_get_height(spr_snake_body)/2);
sprite_set_offset(spr_fruit_normal, sprite_get_width(spr_fruit_normal)/2, sprite_get_height(spr_fruit_normal)/2);
sprite_set_offset(spr_fruit_power, sprite_get_width(spr_fruit_power)/2, sprite_get_height(spr_fruit_power)/2);

grid_snake = ds_list_create();
ds_list_add(grid_snake, {x: 2, y: 4});
ds_list_add(grid_snake, {x: 1, y: 4});
ds_list_add(grid_snake, {x: 0, y: 4});

direction_move = "right";
next_direction = "right";
grow_pending = 0;

scr_spawn_fruit();