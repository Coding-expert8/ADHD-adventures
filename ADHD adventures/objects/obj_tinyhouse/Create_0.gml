scr_init_board();

selected_row = -1;
selected_col = -1;
selected_hand_type = PieceType.NONE;

cell_size  = 100;
board_x    = round((1366 - 4 * cell_size) / 2); // centered horizontally
board_y    = 220;
hand_size  = 72;
hand_gap   = 10;
promo_size = 84;