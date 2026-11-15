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

function scr_piece_sprite(_type, _color) {
    var _kind = "";

    switch (_type) {
        case PieceType.KING:  _kind = "king";   break;
        case PieceType.PAWN:  _kind = "pawn";   break;
        case PieceType.WAZIR: _kind = "rook";   break;
        case PieceType.FERZ:  _kind = "bishop"; break;
        case PieceType.HORSE: _kind = "knight"; break;
    }

    if (_kind == "") return -1;

    var _side = (_color == COLOR_WHITE) ? "white" : "black";
    var _spr = asset_get_index("spr_" + _kind + "_" + _side);

    // Allow either spr_knight_white / spr_knight_black or
    // spr_horse_white / spr_horse_black for the Horse piece.
    if (_spr == -1 && _type == PieceType.HORSE) {
        _spr = asset_get_index("spr_horse_" + _side);
    }

    return _spr;
}

function scr_draw_piece(_type, _color, _cx, _cy, _max_size) {
    var _spr = scr_piece_sprite(_type, _color);

    // A text fallback makes a missing or incorrectly named sprite obvious.
    if (_spr == -1) {
        draw_set_color((_color == COLOR_WHITE) ? c_black : c_white);
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