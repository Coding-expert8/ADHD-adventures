// Rook plays Black by default. If you have a menu that chooses bot colour,
// use the menu's value instead of this default.
if (!variable_global_exists("bot_color")) {
    global.bot_color = 1 - COLOR_WHITE;
}

if (!variable_global_exists("bot_depth")) {
    global.bot_depth = 3;
}

// Keep your current game initialisation.
scr_init_board();

// Reset the one-time loss flag for this new game.
global.rook_heart_penalty_applied = false;


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

if (instance_number(obj_rook) == 0) {
    instance_create_depth(0, 0, 0, obj_rook);
}


if (!variable_global_exists("bot_color")) {
    global.bot_color = 1 - COLOR_WHITE; // Rook is Black by default.
}
if (!variable_global_exists("bot_depth")) {
    global.bot_depth = 3;
}