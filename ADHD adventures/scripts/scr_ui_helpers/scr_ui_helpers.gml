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


// Return the sprite that matches a piece type and colour.
// These are direct asset references, so the names must match the
// Sprite assets in the Asset Browser exactly.
// Wazir uses the chess rook; Ferz uses the chess bishop; Horse uses the knight.
function scr_piece_sprite(_type, _color) {
    var _white = (_color == COLOR_WHITE);

    switch (_type) {
        case PieceType.KING:
            return _white ? spr_king_white : spr_king_black;

        case PieceType.PAWN:
            return _white ? spr_pawn_white : spr_pawn_black;

        case PieceType.WAZIR:
            return _white ? spr_rook_white : spr_rook_black;

        case PieceType.FERZ:
            return _white ? spr_bishop_white : spr_bishop_black;

        case PieceType.HORSE:
            return _white ? spr_knight_white : spr_knight_black;
    }

    // Reached only if _type is not one of the defined PieceType values.
    return -1;
}


// Draw a piece using either the new sprite set or the classic circle-and-letter style.
// global.tinyhouse_pieces == true  : use the image sprites.
// global.tinyhouse_pieces == false : use the original circle with a letter.
// _max_size controls the maximum width/height used by the piece.
function scr_draw_piece(_type, _color, _cx, _cy, _max_size) {
    var _white = (_color == COLOR_WHITE);

    // Classic appearance. This is based on the original board drawing code,
    // and is also used consistently for pieces in hand and promotion choices.
    if (!global.tinyhouse_pieces) {
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

    // New sprite appearance.
    var _spr = scr_piece_sprite(_type, _color);

    // A fallback indicates an unrecognised PieceType value.
    // The sprite assets themselves are direct references above.
    if (_spr == -1) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(_white ? c_black : c_white);
        draw_text(_cx, _cy, scr_piece_letter(_type) + "?");
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