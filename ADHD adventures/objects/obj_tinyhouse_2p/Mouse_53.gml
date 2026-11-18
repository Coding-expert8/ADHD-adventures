if (global.game_over) exit;

 

var _mx = device_mouse_x_to_gui(0);

var _my = device_mouse_y_to_gui(0);

var _side = global.turn; // The side whose turn it currently is.

 

// Promotion must be handled before normal board/hand input.

// Use pending_promotion.color here: some rules engines advance global.turn

// as soon as the pawn moves, before the promotion choice is made.

if (global.pending_promotion != noone) {

    var _promoting_color = global.pending_promotion.color;

    var _opts = [PieceType.WAZIR, PieceType.FERZ, PieceType.HORSE];

 

    for (var i = 0; i < array_length(_opts); i++) {

        var _px = board_x + 4 * cell_size + 40;

        var _py = board_y + i * (promo_size + 8);

 

        if (point_in_rectangle(_mx, _my,

            _px, _py, _px + promo_size, _py + promo_size)) {

            scr_promote(_opts[i]);

            selected_row = -1;

            selected_col = -1;

            selected_hand_type = PieceType.NONE;

            break;

        }

    }

    exit;

}

 

// Select a piece from the hand belonging to the side whose turn it is.

var _hand = global.hand[_side];

var _hand_y = (_side == COLOR_WHITE)

    ? board_y + 4 * cell_size + 24

    : board_y - 24 - hand_size;

 

for (var i = 0; i < array_length(_hand); i++) {

    var _hand_x = board_x + i * (hand_size + hand_gap);

 

    if (point_in_rectangle(_mx, _my,

        _hand_x, _hand_y, _hand_x + hand_size, _hand_y + hand_size)) {

        selected_row = -1;

        selected_col = -1;

        selected_hand_type = (selected_hand_type == _hand[i])

            ? PieceType.NONE

            : _hand[i];

        exit;

    }

}

 

// Convert the click into a 4x4 board cell.

var _col = floor((_mx - board_x) / cell_size);

var _row = floor((_my - board_y) / cell_size);

 

if (_row < 0 || _row > 3 || _col < 0 || _col > 3) {

    selected_row = -1;

    selected_col = -1;

    selected_hand_type = PieceType.NONE;

    exit;

}

 

var _acted = false;

 

// Try to drop a selected hand piece onto this square.

if (selected_hand_type != PieceType.NONE) {

    var _drops = scr_get_legal_drop_squares(selected_hand_type, _side);

 

    for (var i = 0; i < array_length(_drops); i++) {

        if (_drops[i][0] == _row && _drops[i][1] == _col) {

            scr_make_drop(selected_hand_type, _side, _row, _col);

            _acted = true;

            break;

        }

    }

 

    selected_hand_type = PieceType.NONE;

}

// Otherwise, try to move the selected board piece to this square.

else if (selected_row != -1) {

    var _moves = scr_get_legal_moves(selected_row, selected_col);

 

    for (var i = 0; i < array_length(_moves); i++) {

        if (_moves[i][0] == _row && _moves[i][1] == _col) {

            scr_make_move(selected_row, selected_col, _row, _col);

            _acted = true;

            break;

        }

    }

 

    selected_row = -1;

    selected_col = -1;

}

 

// If no move/drop was made, select a piece belonging to the current side.

if (!_acted) {

    var _piece = global.board[_row][_col];

 

    if (_piece != noone && _piece.color == _side) {

        selected_row = _row;

        selected_col = _col;

        selected_hand_type = PieceType.NONE;

    } else {

        selected_row = -1;

        selected_col = -1;

    }

}

 