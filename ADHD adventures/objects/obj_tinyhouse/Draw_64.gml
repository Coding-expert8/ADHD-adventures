draw_clear(make_color_rgb(40, 44, 52));
draw_set_font(-1);

var _light = make_color_rgb(240, 217, 181);
var _dark  = make_color_rgb(181, 136, 99);
var _me = 1 - global.bot_color;
var _my_turn = (!global.game_over && global.pending_promotion == noone && global.turn == _me);


var _targets = [];
if (_my_turn) {
    if (selected_hand_type != PieceType.NONE) {
        _targets = scr_get_legal_drop_squares(selected_hand_type, _me);
    } else if (selected_row != -1) {
        _targets = scr_get_legal_moves(selected_row, selected_col);
    }
}

// --- Board and pieces ---
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

for (var r = 0; r < 4; r++)
for (var c = 0; c < 4; c++) {
    var _x = board_x + c * cell_size;
    var _y = board_y + r * cell_size;

    draw_set_color(((r + c) mod 2 == 0) ? _light : _dark);
    draw_rectangle(_x, _y, _x + cell_size, _y + cell_size, false);

    var _hl_on = false;
    var _hl_col = c_yellow;
    if (r == selected_row && c == selected_col) _hl_on = true;
    for (var i = 0; i < array_length(_targets); i++) {
        if (_targets[i][0] == r && _targets[i][1] == c) { _hl_on = true; _hl_col = c_lime; }
    }
    if (_hl_on) {
        draw_set_alpha(0.55);
        draw_set_color(_hl_col);
        draw_rectangle(_x, _y, _x + cell_size, _y + cell_size, false);
        draw_set_alpha(1);
    }

    var _p = global.board[r][c];
    if (_p != noone) {
        var _cx = _x + cell_size / 2;
        var _cy = _y + cell_size / 2;
        var _white = (_p.color == COLOR_WHITE);
        draw_set_color(_white ? c_white : c_dkgray);
        draw_circle(_cx, _cy, cell_size * 0.38, false);
        draw_set_color(c_black);
        draw_circle(_cx, _cy, cell_size * 0.38, true);
        draw_set_color(_white ? c_black : c_white);
        draw_text_transformed(_cx, _cy, scr_piece_letter(_p.type), 2, 2, 0);
    }
}
draw_set_color(c_black);
draw_rectangle(board_x, board_y, board_x + 4 * cell_size, board_y + 4 * cell_size, true);

// --- Hands (White's below the board, Black's above) ---
for (var _side = 0; _side < 2; _side++) {
    var _h = global.hand[_side];
    var _hy = (_side == COLOR_WHITE) ? board_y + 4 * cell_size + 24 : board_y - 24 - hand_size;

    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text(board_x, _hy - 4, ((_side == COLOR_WHITE) ? "White" : "Black") + " hand");
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var i = 0; i < array_length(_h); i++) {
        var _hx = board_x + i * (hand_size + hand_gap);
        if (_side == _me && _h[i] == selected_hand_type) {
            draw_set_color(c_yellow);
            draw_rectangle(_hx - 3, _hy - 3, _hx + hand_size + 3, _hy + hand_size + 3, false);
        }
        draw_set_color((_side == COLOR_WHITE) ? c_white : c_dkgray);
        draw_rectangle(_hx, _hy, _hx + hand_size, _hy + hand_size, false);
        draw_set_color(c_black);
        draw_rectangle(_hx, _hy, _hx + hand_size, _hy + hand_size, true);
        draw_set_color((_side == COLOR_WHITE) ? c_black : c_white);
        draw_text_transformed(_hx + hand_size / 2, _hy + hand_size / 2, scr_piece_letter(_h[i]), 1.5, 1.5, 0);
    }
}

// --- Promotion menu ---
if (global.pending_promotion != noone && global.pending_promotion.color == _me) {
    var _opts = [PieceType.WAZIR, PieceType.FERZ, PieceType.HORSE];
    for (var i = 0; i < 3; i++) {
        var _px = board_x + 4 * cell_size + 40;
        var _py = board_y + i * (promo_size + 8);
        draw_set_color(c_white);
        draw_rectangle(_px, _py, _px + promo_size, _py + promo_size, false);
        draw_set_color(c_black);
        draw_rectangle(_px, _py, _px + promo_size, _py + promo_size, true);
        draw_text(_px + promo_size / 2, _py + promo_size / 2, scr_piece_name(_opts[i]));
    }
}

// --- Status line ---
var _status;
if (global.game_over) {
    _status = ((global.winner == COLOR_WHITE) ? "White" : "Black") + " wins by " + global.win_reason + "!  Press R to restart.";
} else if (global.pending_promotion != noone && global.pending_promotion.color == _me) {
    _status = "Choose a piece to promote to";
} else if (global.turn == global.bot_color) {
    _status = "Bot is thinking...";
} else {
    _status = "Your move" + (scr_in_check(global.turn) ? " (CHECK)" : "");
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_ext_transformed(board_x + 192, 20, _status, 15, 160, 1.5, 1.5, 0);



draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

//No stalemate
//The losing text goes over screen/overlaps with piece bank if you use draw_text_ext_transformed