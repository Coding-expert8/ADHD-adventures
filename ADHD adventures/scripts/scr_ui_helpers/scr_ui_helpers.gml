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