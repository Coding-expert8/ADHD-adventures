if false {
draw_clear(make_color_rgb(40, 44, 52));
}
draw_set_font(-1);
 
var _light = make_color_rgb(240, 217, 181);
var _dark = make_color_rgb(181, 136, 99);
var _side = (global.pending_promotion != noone)
    ? global.pending_promotion.color
    : global.turn;
var _can_select = (!global.game_over && global.pending_promotion == noone);
 
// Legal destination squares for the currently selected board/hand piece.
var _targets = [];
if (_can_select) {
    if (selected_hand_type != PieceType.NONE) {
        _targets = scr_get_legal_drop_squares(selected_hand_type, _side);
    } else if (selected_row != -1) {
        _targets = scr_get_legal_moves(selected_row, selected_col);
    }
}
 
// Draw the 4x4 board and the pieces on it.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
 
for (var r = 0; r < 4; r++) {
    for (var c = 0; c < 4; c++) {
        var _x = board_x + c * cell_size;
        var _y = board_y + r * cell_size;
 
        draw_set_color(((r + c) mod 2 == 0) ? _light : _dark);
        draw_rectangle(_x, _y, _x + cell_size, _y + cell_size, false);
 
        var _highlight = false;
        var _highlight_color = c_yellow;
 
        if (r == selected_row && c == selected_col) {
            _highlight = true;
        }
 
        for (var i = 0; i < array_length(_targets); i++) {
            if (_targets[i][0] == r && _targets[i][1] == c) {
                _highlight = true;
                _highlight_color = c_lime;
            }
        }
 
        if (_highlight) {
            draw_set_alpha(0.55);
            draw_set_color(_highlight_color);
            draw_rectangle(_x, _y, _x + cell_size, _y + cell_size, false);
            draw_set_alpha(1);
        }
 
        var _piece = global.board[r][c];
        if (_piece != noone) {
            var _cx = _x + cell_size * 0.5;
            var _cy = _y + cell_size * 0.5;
            scr_draw_piece(_piece.type, _piece.color,
                _cx, _cy, cell_size * 0.84);
        }
    }
}
 
// Board outline.
draw_set_color(c_black);
draw_rectangle(board_x, board_y,
    board_x + 4 * cell_size, board_y + 4 * cell_size, true);
 
// Draw both players' hands. Only the hand belonging to global.turn is active.
for (var _hand_side = 0; _hand_side < 2; _hand_side++) {
    var _pieces_in_hand = global.hand[_hand_side];
    var _hy = (_hand_side == COLOR_WHITE)
        ? board_y + 4 * cell_size + 24
        : board_y - 24 - hand_size;
 
    draw_set_halign(fa_left);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
	draw_set_font(fnt_score);
    draw_text(board_x, _hy+4,
        (_hand_side == COLOR_WHITE ? "White" : "Black") + " hand");
 
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
 
    for (var i = 0; i < array_length(_pieces_in_hand); i++) {
        var _hx = board_x + i * (hand_size + hand_gap);
 
        if (_hand_side == _side && _pieces_in_hand[i] == selected_hand_type) {
            draw_set_color(c_yellow);
            draw_rectangle(_hx - 3, _hy - 3,
                _hx + hand_size + 3, _hy + hand_size + 3, false);
        }
 
        draw_set_color((_hand_side == COLOR_WHITE) ? c_white : c_dkgray);
        draw_rectangle(_hx, _hy, _hx + hand_size, _hy + hand_size, false);
        draw_set_color(c_black);
        draw_rectangle(_hx, _hy, _hx + hand_size, _hy + hand_size, true);
 
        scr_draw_piece(_pieces_in_hand[i], _hand_side,
            _hx + hand_size * 0.5, _hy + hand_size * 0.5,
            hand_size * 0.82);
    }
}
 
// Promotion menu: show the available pieces as the currently selected style.
if (global.pending_promotion != noone) {
    var _promoting_color = global.pending_promotion.color;
    var _opts = [PieceType.WAZIR, PieceType.FERZ, PieceType.HORSE];
 
    for (var i = 0; i < array_length(_opts); i++) {
        var _px = board_x + 4 * cell_size + 40;
        var _py = board_y + i * (promo_size + 8);
 
        draw_set_color(c_white);
        draw_rectangle(_px, _py, _px + promo_size, _py + promo_size, false);
        draw_set_color(c_black);
        draw_rectangle(_px, _py, _px + promo_size, _py + promo_size, true);
 
        scr_draw_piece(_opts[i], _promoting_color,
            _px + promo_size * 0.5, _py + promo_size * 0.5,
            promo_size * 0.82);
    }
}
 
// Status line: clearly identify which colour the one human player controls next.
var _status;
var _side_name = (_side == COLOR_WHITE) ? "White" : "Black";
draw_set_font(fnt_title);
draw_set_colour(c_red);
if (global.game_over) {
    if (global.winner == COLOR_WHITE) {
        _status = "White wins by " + string(global.win_reason) + "!  Press R to restart.";
    } else if (global.winner == (1 - COLOR_WHITE)) {
        _status = "Black wins by " + string(global.win_reason) + "!  Press R to restart.";
    } else {
        _status = "Game over: " + string(global.win_reason) + ".  Press R to restart.";
    }
} else if (global.pending_promotion != noone) {
    _status = _side_name + " - choose promotion piece";
} else {
    _status = _side_name + " to move";
    if (scr_in_check(global.turn)) {
        _status += " (CHECK)";
    }
}
 
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(board_x, 18, _status, 1.35, 1.35, 0);
 
// Restore normal drawing state for other GUI drawing code.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
