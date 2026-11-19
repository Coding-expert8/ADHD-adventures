scr_init_board();

 

// Set a default only if another menu/button has not already chosen a style.

if (!variable_global_exists("tinyhouse_pieces")) {

    global.tinyhouse_pieces = 1;

}

global.tinyhouse_pieces = clamp(floor(global.tinyhouse_pieces), 0, 3);

 

selected_row = -1;

selected_col = -1;

selected_hand_type = PieceType.NONE;

 

cell_size = 91;

board_x = 150;

board_y = 248;

hand_size = 96;

hand_gap = 16;

promo_size = 91;