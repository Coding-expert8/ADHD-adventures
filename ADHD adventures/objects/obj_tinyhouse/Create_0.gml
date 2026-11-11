scr_init_board();

selected_row = -1;
selected_col = -1;
selected_hand_type = PieceType.NONE;

if global.tinyhouseready {
	cell_size = 100;
	board_x    = round((1366 - 4 * cell_size) / 2);
	board_y = 200;
}
else {
	cell_size  = 50;
	board_x    = round((1366 - 4 * cell_size) / 5);
	board_y    = 100;
}
hand_size  = 72;
hand_gap   = 10;
promo_size = 84;