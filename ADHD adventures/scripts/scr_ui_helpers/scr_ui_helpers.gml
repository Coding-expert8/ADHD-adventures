// SECTION 1 - EXISTING SCRIPT ASSET: scr_ui_helpers

// Replace the contents of your existing scr_ui_helpers script with this section.

// Do not keep a second copy of functions with the same names in another script.

// ============================================================================

 

function scr_piece_letter(_type) {

    switch (_type) {

        case PieceType.KING:  return "K";

        case PieceType.PAWN:  return "P";

        case PieceType.WAZIR: return "W";

        case PieceType.FERZ:  return "F";

        case PieceType.HORSE: return "H";

    }

    return "?";

}

 

function scr_piece_name(_type) {

    switch (_type) {

        case PieceType.KING:  return "King";

        case PieceType.PAWN:  return "Pawn";

        case PieceType.WAZIR: return "Wazir";

        case PieceType.FERZ:  return "Ferz";

        case PieceType.HORSE: return "Horse";

    }

    return "?";

}

 

// Return the correct sprite for a piece type, colour and visual style.

// Black Ferz and black special Wazir/Ferz use the standard black sprite,

// because only the white versions of those special assets were supplied.

function scr_piece_sprite(_type, _color) {

    var _white = (_color == COLOR_WHITE);

    var _style = clamp(floor(global.tinyhouse_pieces), 0, 3);

 

    switch (_type) {

        case PieceType.KING:

            return _white ? spr_king_white : spr_king_black;

 

        case PieceType.PAWN:

            return _white ? spr_pawn_white : spr_pawn_black;

 

        case PieceType.HORSE:

            return _white ? spr_knight_white : spr_knight_black;

 

        case PieceType.WAZIR:

            if (_style == 2) {

                return _white ? spr_wazir_white : spr_wazir_black;

            }

            if (_style == 3) {

                return _white ? spr_rook_special_white : spr_rook_black;

            }

            return _white ? spr_rook_white : spr_rook_black;

 

        case PieceType.FERZ:

            if (_style == 2) {

                return _white ? spr_ferz_white : spr_bishop_black;

            }

            if (_style == 3) {

                return _white ? spr_bishop_special_white : spr_bishop_black;

            }

            return _white ? spr_bishop_white : spr_bishop_black;

    }

 

    return -1;

}

 

// Draw either the original circle/letter or the currently selected sprite.

function scr_draw_piece(_type, _color, _cx, _cy, _max_size) {

    var _white = (_color == COLOR_WHITE);

    var _style = clamp(floor(global.tinyhouse_pieces), 0, 3);

 

    if (_style == 0) {

        var _radius = _max_size * (0.38 / 0.84);

        var _text_scale = _max_size / 26.88;

 

        draw_set_halign(fa_center);

        draw_set_valign(fa_middle);

 

        draw_set_color(_white ? c_white : c_dkgray);

        draw_circle(_cx, _cy, _radius, false);

        draw_set_color(c_black);

        draw_circle(_cx, _cy, _radius, true);

        draw_set_color(_white ? c_black : c_white);

        draw_text_transformed(_cx, _cy, scr_piece_letter(_type),

            _text_scale, _text_scale, 0);

        draw_set_color(c_white);

        return;

    }

 

    var _spr = scr_piece_sprite(_type, _color);

    if (_spr == -1) {

        draw_set_halign(fa_center);

        draw_set_valign(fa_middle);

        draw_set_color(_white ? c_black : c_white);

        draw_text(_cx, _cy, scr_piece_letter(_type));

        draw_set_color(c_white);

        return;

    }

 

    var _sw = sprite_get_width(_spr);

    var _sh = sprite_get_height(_spr);

    if (_sw <= 0 || _sh <= 0) return;

 

    // Fit the sprite inside a square without changing its aspect ratio.

    var _scale = min(_max_size / _sw, _max_size / _sh);

 

    // Centre the visible sprite even if the sprite origin is not centred.

    var _draw_x = _cx - (_sw * _scale * 0.5)

        + sprite_get_xoffset(_spr) * _scale;

    var _draw_y = _cy - (_sh * _scale * 0.5)

        + sprite_get_yoffset(_spr) * _scale;

 

    draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);

}