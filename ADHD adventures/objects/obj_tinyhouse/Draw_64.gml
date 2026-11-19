
draw_set_font(-1);

var _light = make_color_rgb(240, 217, 181);
var _dark  = make_color_rgb(181, 136, 99);
var _me = 1 - global.bot_color;
var _my_turn = (!global.game_over && global.pending_promotion == noone && global.turn == _me);

// Squares the current selection can move or drop to
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
        scr_draw_piece(_p.type, _p.color, _cx, _cy, cell_size * 0.84);
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
        scr_draw_piece(_h[i], _side, _hx + hand_size / 2, _hy + hand_size / 2, hand_size * 0.82);
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
        scr_draw_piece(_opts[i], global.pending_promotion.color,
            _px + promo_size / 2, _py + promo_size / 2, promo_size * 0.82);
    }
}

// --- Status line ---
var _status;
if (global.game_over) {
    if (global.winner == _me) _status = "You win by " + global.win_reason + "!  Back to the map...";
    else _status = ((global.winner == COLOR_WHITE) ? "White" : "Black") + " wins by " + global.win_reason + "!  Press R to restart.";
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
draw_text_transformed(board_x, 24, _status, 1.5, 1.5, 0);

// reset drawing state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);


var _rook_id = instance_find(obj_rook, 0);
if (_rook_id != noone) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();

    // Draw Rook in the lower-right area, scaled without changing proportions.
    var _rook_sw = sprite_get_width(spr_rook_npc);
    var _rook_sh = sprite_get_height(spr_rook_npc);
    var _rook_scale = min(1.0,
        min((_gui_h * 0.75) / _rook_sh,
            (_gui_w * 0.40) / _rook_sw));

    var _rook_cx = _gui_w - 250;
    var _rook_cy = _gui_h - 250;
    var _rook_x = _rook_cx - (_rook_sw * _rook_scale * 0.5)
        + sprite_get_xoffset(spr_rook_npc) * _rook_scale;
    var _rook_y = _rook_cy - (_rook_sh * _rook_scale * 0.5)
        + sprite_get_yoffset(spr_rook_npc) * _rook_scale;

    draw_sprite_ext(spr_rook_npc, 0,
        _rook_x, _rook_y, _rook_scale, _rook_scale, 0, c_white, 1);

    // Draw the bubble only while a dialogue line is active.
    if (global.rook_speech_timer > 0 && global.rook_speech_text != "") {
        var _bubble_w = min(410, _gui_w * 0.34);
        var _bubble_x = _gui_w - _bubble_w - 34;
        var _bubble_y = 100;
        var _text_x = _bubble_x + 23;
        var _text_y = _bubble_y + 57;
        var _text_w = _bubble_w - 46;

        // draw_text_ext's sep argument is the line-to-line distance in pixels.
        // The previous value of 4 pixels was far too small and caused overlap.
        var _line_sep = max(22, string_height("M") + 8);
        var _text_h = string_height_ext(
            global.rook_speech_text, _line_sep, _text_w);

        // Give longer messages extra vertical room, within a sensible limit.
        var _bubble_h = clamp(75 + _text_h, 175, 260);

        draw_sprite_stretched(spr_speech_bubble, 0,
            _bubble_x, _bubble_y, _bubble_w, _bubble_h);

        draw_set_font(-1);
        draw_set_color(c_black);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_text(_text_x+150, _bubble_y + 13, "Rook");
        draw_line(_bubble_x + 22, _bubble_y + 40,
            _bubble_x + _bubble_w - 22, _bubble_y + 40);

        draw_text_ext(_text_x, _text_y,
            global.rook_speech_text, _line_sep, _text_w);
    }
}

// Restore drawing state for other GUI drawing code.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);