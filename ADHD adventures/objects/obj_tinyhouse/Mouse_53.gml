if (global.game_over) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
// show_debug_message("click at " + string(_mx) + ", " + string(_my)); // uncomment to test that clicks arrive

var _me = 1 - global.bot_color;   // the human's colour
var _delay = round(game_get_speed(gamespeed_fps) * 0.4);

// --- Promotion menu (must be handled first, or the game locks up) ---
if (global.pending_promotion != noone) {
    if (global.pending_promotion.color == _me) {
        var _opts = [PieceType.WAZIR, PieceType.FERZ, PieceType.HORSE];
        for (var i = 0; i < 3; i++) {
            var _px = board_x + 4 * cell_size + 40;
            var _py = board_y + i * (promo_size + 8);
            if (point_in_rectangle(_mx, _my, _px, _py, _px + promo_size, _py + promo_size)) {
                scr_promote(_opts[i]);
                if (!global.game_over && global.turn == global.bot_color) alarm[0] = _delay;
                break;
            }
        }
    }
    exit;
}

if (global.turn == global.bot_color) exit; // not the human's turn

// --- Clicking a piece in your hand ---
var _hand = global.hand[_me];
var _hy = (_me == COLOR_WHITE) ? board_y + 4 * cell_size + 24 : board_y - 24 - hand_size;
for (var i = 0; i < array_length(_hand); i++) {
    var _hx = board_x + i * (hand_size + hand_gap);
    if (point_in_rectangle(_mx, _my, _hx, _hy, _hx + hand_size, _hy + hand_size)) {
        selected_row = -1;
        selected_col = -1;
        selected_hand_type = (selected_hand_type == _hand[i]) ? PieceType.NONE : _hand[i];
        exit;
    }
}

// --- Clicking the board ---
var _col = floor((_mx - board_x) / cell_size);
var _row = floor((_my - board_y) / cell_size);
if (_row < 0 || _row > 3 || _col < 0 || _col > 3) {
    selected_row = -1;
    selected_col = -1;
    selected_hand_type = PieceType.NONE;
    exit;
}

var _acted = false;

if (selected_hand_type != PieceType.NONE) {
    var _drops = scr_get_legal_drop_squares(selected_hand_type, global.turn);
    for (var i = 0; i < array_length(_drops); i++) {
        if (_drops[i][0] == _row && _drops[i][1] == _col) {
            scr_make_drop(selected_hand_type, global.turn, _row, _col);
            _acted = true;
            break;
        }
    }
    selected_hand_type = PieceType.NONE;
} else if (selected_row != -1) {
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

if (!_acted) {
    var _piece = global.board[_row][_col];
    if (_piece != noone && _piece.color == global.turn) {
        selected_row = _row;
        selected_col = _col;
    }
}

// Hand off to the bot once the human's turn is completely finished
if (_acted && !global.game_over && global.pending_promotion == noone
    && global.turn == global.bot_color) {
    alarm[0] = _delay;
}