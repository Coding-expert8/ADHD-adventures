scr_init_board();

 

// Set a default only if another menu/button has not already chosen a style.

if (!variable_global_exists("tinyhouse_pieces")) {

    global.tinyhouse_pieces = 1;

}

global.tinyhouse_pieces = clamp(floor(global.tinyhouse_pieces), 0, 3);

 

selected_row = -1;

selected_col = -1;

selected_hand_type = PieceType.NONE;

 

cell_size = 64;

board_x = 120;

board_y = 128;

hand_size = 48;

hand_gap = 8;

promo_size = 56;