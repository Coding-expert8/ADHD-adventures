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


// Return the sprite that matches a piece type, colour and selected style.
// Style 0 is handled by scr_draw_piece and does not need sprites.
// Style 1: standard chess sprites (rook = Wazir, bishop = Ferz).
// Style 2: dedicated Wazir and Ferz sprites.
// Style 3: special rook and bishop sprites.
function scr_piece_sprite(_type, _color) {
    var _white = (_color == COLOR_WHITE);
    var _style = global.tinyhouse_pieces;

    switch (_type) {
        case PieceType.KING:
            return _white ? spr_king_white : spr_king_black;

        case PieceType.PAWN:
            return _white ? spr_pawn_white : spr_pawn_black;

        case PieceType.WAZIR:
            if (_style == 2) {
                return _white ? spr_wazir_white : spr_wazir_black;
            }
            if (_style == 3) {
                // Only the white special sprite name was supplied.
                // Keep the normal black rook sprite for black Wazirs.
                return _white ? spr_rook_special_white : spr_rook_black;
            }
            // Styles 1 and any unrecognised style use the standard rook.
            return _white ? spr_rook_white : spr_rook_black;

        case PieceType.FERZ:
            if (_style == 2) {
                // Only spr_ferz_white was supplied. The black Ferz therefore
                // keeps the standard black bishop until a black Ferz asset is added.
                return _white ? spr_ferz_white : spr_ferz_black;
            }
            if (_style == 3) {
                // Only the white special sprite name was supplied.
                // Keep the normal black bishop sprite for black Ferz.
                return _white ? spr_bishop_special_white : spr_bishop_special_black;
            }
            // Styles 1 and any unrecognised style use the standard bishop.
            return _white ? spr_bishop_white : spr_bishop_black;

        case PieceType.HORSE:
            return _white ? spr_knight_white : spr_knight_black;
    }

    // Reached only if _type is not one of the defined PieceType values.
    return -1;
}


// Draw a piece using one of the four styles:
// 0 = original circle and letter
// 1 = standard chess-piece sprites
// 2 = dedicated Wazir and Ferz sprites
// 3 = special rook and bishop sprites
// _max_size controls the maximum width/height used by the piece.
function scr_draw_piece(_type, _color, _cx, _cy, _max_size) {
    var _white = (_color == COLOR_WHITE);
    var _style = global.tinyhouse_pieces;

    // Style 0: original circle-and-letter appearance.
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
        draw_text_transformed(_cx, _cy, scr_piece_letter(_type), _text_scale, _text_scale, 0);
        draw_set_color(c_white);
        return;
    }

    // Styles 1-3: draw the selected sprite set.
    var _spr = scr_piece_sprite(_type, _color);

    // Fallback for an unrecognised PieceType value.
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

    // Fit inside a square without stretching the sprite.
    var _scale = min(_max_size / _sw, _max_size / _sh);

    // Account for the sprite origin so the visible sprite is centred,
    // whether its origin is centred or at the top-left.
    var _draw_x = _cx - (_sw * _scale * 0.5) + sprite_get_xoffset(_spr) * _scale;
    var _draw_y = _cy - (_sh * _scale * 0.5) + sprite_get_yoffset(_spr) * _scale;

    draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);
}