function scr_init_board() {
    global.board = array_create(4);
    for (var r = 0; r < 4; r++) global.board[r] = array_create(4, noone);

    global.board[0][0] = scr_make_piece(PieceType.HORSE, COLOR_BLACK);
    global.board[0][1] = scr_make_piece(PieceType.FERZ,  COLOR_BLACK);
    global.board[0][2] = scr_make_piece(PieceType.KING,  COLOR_BLACK);
    global.board[0][3] = scr_make_piece(PieceType.WAZIR, COLOR_BLACK);

    global.board[1][2] = scr_make_piece(PieceType.PAWN, COLOR_BLACK);
    global.board[2][1] = scr_make_piece(PieceType.PAWN, COLOR_WHITE);

    global.board[3][0] = scr_make_piece(PieceType.WAZIR, COLOR_WHITE);
    global.board[3][1] = scr_make_piece(PieceType.KING,  COLOR_WHITE);
    global.board[3][2] = scr_make_piece(PieceType.FERZ,  COLOR_WHITE);
    global.board[3][3] = scr_make_piece(PieceType.HORSE, COLOR_WHITE);

    global.hand = [[], []]; // global.hand[COLOR_WHITE], global.hand[COLOR_BLACK]

    global.turn = COLOR_WHITE;
    global.pending_promotion = noone;   // struct {row, col, color} while awaiting a pick
    global.game_over = false;
    global.winner = noone;
    global.win_reason = "";             // "checkmate" or "stalemate"

    global.bot_color = COLOR_BLACK;     // the human plays White by default
    global.bot_depth = 3;               // 2 = fast/weak, 4+ = slower/stronger
}

// --- Piece types ---
enum PieceType {
    NONE,
    KING,
    PAWN,
    WAZIR,
    FERZ,
    HORSE
}

// --- Colors ---
#macro COLOR_WHITE 0
#macro COLOR_BLACK 1

// --- Movement direction tables (row, col) ---
global.DIR_WAZIR = [[-1,0],[1,0],[0,-1],[0,1]];
global.DIR_FERZ  = [[-1,-1],[-1,1],[1,-1],[1,1]];
global.DIR_KING  = [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]];
global.DIR_HORSE = [[-2,-1],[-2,1],[2,-1],[2,1],[-1,-2],[-1,2],[1,-2],[1,2]];

function scr_make_piece(_type, _color) {
    return { type: _type, color: _color };
}

function scr_array_find(_arr, _value) {
    for (var i = 0; i < array_length(_arr); i++) {
        if (_arr[i] == _value) return i;
    }
    return -1;
}

function scr_array_copy(_arr) {
    var _new = array_create(array_length(_arr));
    for (var i = 0; i < array_length(_arr); i++) _new[i] = _arr[i];
    return _new;
}

function scr_step_moves(_row, _col, _dirs) {
    var _piece = global.board[_row][_col];
    var _moves = [];
    for (var i = 0; i < array_length(_dirs); i++) {
        var _r = _row + _dirs[i][0];
        var _c = _col + _dirs[i][1];
        if (_r < 0 || _r > 3 || _c < 0 || _c > 3) continue;
        var _target = global.board[_r][_c];
        if (_target == noone || _target.color != _piece.color) {
            array_push(_moves, [_r, _c]);
        }
    }
    return _moves;
}

function scr_get_horse_moves(_row, _col) {
    // Xiangqi horse: a (1,2)-leaper that is blocked ("hobbled") if the
    // orthogonal square it steps over first is occupied — unlike a
    // standard chess knight, which can never be blocked.
    var _piece = global.board[_row][_col];
    var _moves = [];
    for (var i = 0; i < array_length(global.DIR_HORSE); i++) {
        var _dr = global.DIR_HORSE[i][0];
        var _dc = global.DIR_HORSE[i][1];
        var _r = _row + _dr;
        var _c = _col + _dc;
        if (_r < 0 || _r > 3 || _c < 0 || _c > 3) continue;

        var _legR, _legC;
        if (abs(_dr) == 2) { _legR = _row + sign(_dr); _legC = _col; }
        else               { _legR = _row; _legC = _col + sign(_dc); }
        if (global.board[_legR][_legC] != noone) continue; // leg is blocked

        var _target = global.board[_r][_c];
        if (_target == noone || _target.color != _piece.color) {
            array_push(_moves, [_r, _c]);
        }
    }
    return _moves;
}

function scr_get_pawn_moves(_row, _col) {
    var _piece = global.board[_row][_col];
    var _dir = (_piece.color == COLOR_WHITE) ? -1 : 1; // white advances toward row 0
    var _moves = [];
    var _fr = _row + _dir;

    if (_fr >= 0 && _fr <= 3 && global.board[_fr][_col] == noone) {
        array_push(_moves, [_fr, _col]);
    }
    var _diag = [-1, 1];
    for (var i = 0; i < 2; i++) {
        var _c = _col + _diag[i];
        if (_c < 0 || _c > 3 || _fr < 0 || _fr > 3) continue;
        var _target = global.board[_fr][_c];
        if (_target != noone && _target.color != _piece.color) {
            array_push(_moves, [_fr, _c]);
        }
    }
    return _moves; // no double-step, no en passant — the board is too small for either
}

function scr_get_moves(_row, _col) {
    var _piece = global.board[_row][_col];
    if (_piece == noone) return [];
    switch (_piece.type) {
        case PieceType.WAZIR: return scr_step_moves(_row, _col, global.DIR_WAZIR);
        case PieceType.FERZ:  return scr_step_moves(_row, _col, global.DIR_FERZ);
        case PieceType.KING:  return scr_step_moves(_row, _col, global.DIR_KING);
        case PieceType.HORSE: return scr_get_horse_moves(_row, _col);
        case PieceType.PAWN:  return scr_get_pawn_moves(_row, _col);
    }
    return [];
}

function scr_find_king(_color) {
    for (var r = 0; r < 4; r++)
    for (var c = 0; c < 4; c++) {
        var _p = global.board[r][c];
        if (_p != noone && _p.type == PieceType.KING && _p.color == _color) {
            return [r, c];
        }
    }
    return [-1, -1]; // should never happen — kings can't be dropped or captured legally
}

function scr_is_square_attacked(_row, _col, _by_color) {
    for (var r = 0; r < 4; r++)
    for (var c = 0; c < 4; c++) {
        var _p = global.board[r][c];
        if (_p == noone || _p.color != _by_color) continue;
        var _moves = scr_get_moves(r, c);
        for (var i = 0; i < array_length(_moves); i++) {
            if (_moves[i][0] == _row && _moves[i][1] == _col) return true;
        }
    }
    return false;
}

function scr_in_check(_color) {
    var _k = scr_find_king(_color);
    return scr_is_square_attacked(_k[0], _k[1], 1 - _color);
}

// Board moves that don't leave your own king in check.
// The board is tiny, so a make/check/unmake per candidate is cheap.
function scr_get_legal_moves(_row, _col) {
    var _piece = global.board[_row][_col];
    var _pseudo = scr_get_moves(_row, _col);
    var _legal = [];
    for (var i = 0; i < array_length(_pseudo); i++) {
        var _tr = _pseudo[i][0];
        var _tc = _pseudo[i][1];
        var _captured = global.board[_tr][_tc];

        global.board[_tr][_tc] = _piece;
        global.board[_row][_col] = noone;
        if (!scr_in_check(_piece.color)) array_push(_legal, [_tr, _tc]);
        global.board[_row][_col] = _piece;
        global.board[_tr][_tc] = _captured;
    }
    return _legal;
}

function scr_get_drop_squares(_type, _color) {
    var _squares = [];
    for (var r = 0; r < 4; r++)
    for (var c = 0; c < 4; c++) {
        if (global.board[r][c] != noone) continue;
        if (_type == PieceType.PAWN) {
            var _back = (_color == COLOR_WHITE) ? 0 : 3;
            if (r == _back) continue; // can't drop a pawn onto its own promotion rank
        }
        array_push(_squares, [r, c]);
    }
    return _squares;
}

// Dropping a friendly piece can never expose your OWN king, but if you're
// already in check the drop must actually resolve it, so simulate anyway.
function scr_get_legal_drop_squares(_type, _color) {
    var _all = scr_get_drop_squares(_type, _color);
    var _legal = [];
    for (var i = 0; i < array_length(_all); i++) {
        var _r = _all[i][0];
        var _c = _all[i][1];
        global.board[_r][_c] = scr_make_piece(_type, _color);
        if (!scr_in_check(_color)) array_push(_legal, [_r, _c]);
        global.board[_r][_c] = noone;
    }
    return _legal;
}

function scr_make_move(_fr, _fc, _tr, _tc) {
    var _mover = global.board[_fr][_fc];
    var _captured = global.board[_tr][_tc];

    if (_captured != noone) {
        array_push(global.hand[_mover.color], _captured.type); // Crazyhouse: captured pieces switch sides
    }

    global.board[_tr][_tc] = _mover;
    global.board[_fr][_fc] = noone;

    var _back = (_mover.color == COLOR_WHITE) ? 0 : 3;
    if (_mover.type == PieceType.PAWN && _tr == _back) {
        global.pending_promotion = { row: _tr, col: _tc, color: _mover.color };
    } else {
        scr_end_turn();
    }
}

function scr_make_drop(_type, _color, _r, _c) {
    global.board[_r][_c] = scr_make_piece(_type, _color);
    var _idx = scr_array_find(global.hand[_color], _type);
    array_delete(global.hand[_color], _idx, 1);
    scr_end_turn();
}

// Call with PieceType.WAZIR, PieceType.FERZ or PieceType.HORSE only —
// promotion to a queen/rook/bishop doesn't exist in this variant.
function scr_promote(_type) {
    var _p = global.pending_promotion;
    global.board[_p.row][_p.col] = scr_make_piece(_type, _p.color);
    global.pending_promotion = noone;
    scr_end_turn();
}

function scr_end_turn() {
    global.turn = 1 - global.turn;
    scr_check_game_end();
}

function scr_has_any_legal_move(_color) {
    for (var r = 0; r < 4; r++)
    for (var c = 0; c < 4; c++) {
        var _p = global.board[r][c];
        if (_p != noone && _p.color == _color) {
            if (array_length(scr_get_legal_moves(r, c)) > 0) return true;
        }
    }

    var _hand = global.hand[_color];
    var _seen = [];
    for (var i = 0; i < array_length(_hand); i++) {
        var _type = _hand[i];
        if (scr_array_find(_seen, _type) != -1) continue;
        array_push(_seen, _type);
        if (array_length(scr_get_legal_drop_squares(_type, _color)) > 0) return true;
    }
    return false;
}

function scr_check_game_end() {
    var _color = global.turn;
    if (scr_has_any_legal_move(_color)) return;

    global.game_over = true;
    if (scr_in_check(_color)) {
        global.winner = 1 - _color;     // checkmate — the mated side loses, as usual
        global.win_reason = "checkmate";
    } else {
        global.winner = _color;         // Tinyhouse's signature reversal
        global.win_reason = "stalemate";
    }
}

function scr_clone_board(_board) {
    var _new = array_create(4);
    for (var r = 0; r < 4; r++) {
        _new[r] = array_create(4, noone);
        for (var c = 0; c < 4; c++) {
            var _p = _board[r][c];
            _new[r][c] = (_p == noone) ? noone : scr_make_piece(_p.type, _p.color);
        }
    }
    return _new;
}

function scr_piece_value(_type) {
    switch (_type) {
        case PieceType.PAWN:  return 100;
        case PieceType.WAZIR: return 200;
        case PieceType.FERZ:  return 220;
        case PieceType.HORSE: return 300;
    }
    return 0; // KING isn't scored as material — checkmate is handled separately
}

function scr_evaluate() {
    // Positive favors White, negative favors Black.
    var _score = 0;
    for (var r = 0; r < 4; r++)
    for (var c = 0; c < 4; c++) {
        var _p = global.board[r][c];
        if (_p == noone) continue;
        var _v = scr_piece_value(_p.type);
        _score += (_p.color == COLOR_WHITE) ? _v : -_v;
    }
    // Pieces in hand count for roughly half value — they still need a tempo to drop.
    for (var i = 0; i < array_length(global.hand[COLOR_WHITE]); i++) {
        _score += scr_piece_value(global.hand[COLOR_WHITE][i]) * 0.5;
    }
    for (var i = 0; i < array_length(global.hand[COLOR_BLACK]); i++) {
        _score -= scr_piece_value(global.hand[COLOR_BLACK][i]) * 0.5;
    }
    return _score;
}

// Every legal action for _color, as {kind:"move",...} or {kind:"drop",...}.
function scr_generate_all_moves(_color) {
    var _moves = [];
    for (var r = 0; r < 4; r++)
    for (var c = 0; c < 4; c++) {
        var _p = global.board[r][c];
        if (_p == noone || _p.color != _color) continue;
        var _dests = scr_get_legal_moves(r, c);
        for (var i = 0; i < array_length(_dests); i++) {
            array_push(_moves, { kind: "move", fr: r, fc: c, tr: _dests[i][0], tc: _dests[i][1] });
        }
    }
    var _seen = [];
    var _hand = global.hand[_color];
    for (var i = 0; i < array_length(_hand); i++) {
        var _type = _hand[i];
        if (scr_array_find(_seen, _type) != -1) continue;
        array_push(_seen, _type);
        var _drops = scr_get_legal_drop_squares(_type, _color);
        for (var j = 0; j < array_length(_drops); j++) {
            array_push(_moves, { kind: "drop", type: _type, r: _drops[j][0], c: _drops[j][1] });
        }
    }
    return _moves;
}

// Mutates the live board/hand for search purposes only — no turn switching,
// no UI promotion pause. Promotions during search auto-pick Ferz to keep the
// branching factor down; only the bot's real, top-level promotion (below)
// actually compares all three options.
function scr_search_apply_move(_move, _color) {
    if (_move.kind == "move") {
        var _mover = global.board[_move.fr][_move.fc];
        var _captured = global.board[_move.tr][_move.tc];
        if (_captured != noone) array_push(global.hand[_color], _captured.type);

        var _final_type = _mover.type;
        var _back = (_color == COLOR_WHITE) ? 0 : 3;
        if (_mover.type == PieceType.PAWN && _move.tr == _back) _final_type = PieceType.FERZ;

        global.board[_move.tr][_move.tc] = scr_make_piece(_final_type, _color);
        global.board[_move.fr][_move.fc] = noone;
    } else {
        global.board[_move.r][_move.c] = scr_make_piece(_move.type, _color);
        var _idx = scr_array_find(global.hand[_color], _move.type);
        array_delete(global.hand[_color], _idx, 1);
    }
}

function scr_negamax(_depth, _alpha, _beta, _color) {
    var _moves = scr_generate_all_moves(_color);
    if (array_length(_moves) == 0) {
        // No legal move: checkmate is bad for the side to move, but Tinyhouse's
        // reversed stalemate rule makes a non-check "stuck" position a big win.
        return scr_in_check(_color) ? (-100000 - _depth) : (100000 + _depth);
    }
    if (_depth == 0) {
        var _e = scr_evaluate();
        return (_color == COLOR_WHITE) ? _e : -_e;
    }

    var _best = -999999;
    for (var i = 0; i < array_length(_moves); i++) {
        var _snap_board = scr_clone_board(global.board);
        var _snap_hand_w = scr_array_copy(global.hand[COLOR_WHITE]);
        var _snap_hand_b = scr_array_copy(global.hand[COLOR_BLACK]);

        scr_search_apply_move(_moves[i], _color);
        var _score = -scr_negamax(_depth - 1, -_beta, -_alpha, 1 - _color);

        global.board = _snap_board;
        global.hand[COLOR_WHITE] = _snap_hand_w;
        global.hand[COLOR_BLACK] = _snap_hand_b;

        if (_score > _best) _best = _score;
        if (_best > _alpha) _alpha = _best;
        if (_alpha >= _beta) break; // alpha-beta cutoff
    }
    return _best;
}

function scr_bot_choose_move(_color, _depth) {
    var _moves = scr_generate_all_moves(_color);
    if (array_length(_moves) == 0) return noone;

    var _best_move = _moves[0];
    var _best_score = -999999;
    var _alpha = -999999;
    var _beta = 999999;

    for (var i = 0; i < array_length(_moves); i++) {
        var _snap_board = scr_clone_board(global.board);
        var _snap_hand_w = scr_array_copy(global.hand[COLOR_WHITE]);
        var _snap_hand_b = scr_array_copy(global.hand[COLOR_BLACK]);

        scr_search_apply_move(_moves[i], _color);
        var _score = -scr_negamax(_depth - 1, -_beta, -_alpha, 1 - _color);

        global.board = _snap_board;
        global.hand[COLOR_WHITE] = _snap_hand_w;
        global.hand[COLOR_BLACK] = _snap_hand_b;

        if (_score > _best_score) { _best_score = _score; _best_move = _moves[i]; }
        if (_best_score > _alpha) _alpha = _best_score;
    }
    return _best_move;
}

// Picks the best of the three real promotion pieces, one ply deep.
function scr_bot_choose_promotion() {
    var _p = global.pending_promotion;
    var _candidates = [PieceType.WAZIR, PieceType.FERZ, PieceType.HORSE];
    var _best_type = PieceType.FERZ;
    var _best_score = -999999;

    for (var i = 0; i < 3; i++) {
        var _snap_board = scr_clone_board(global.board);
        global.board[_p.row][_p.col] = scr_make_piece(_candidates[i], _p.color);
        var _e = scr_evaluate();
        var _score = (_p.color == COLOR_WHITE) ? _e : -_e;
        global.board = _snap_board;
        if (_score > _best_score) { _best_score = _score; _best_type = _candidates[i]; }
    }
    scr_promote(_best_type);
}

// Call this once whenever it becomes the bot's turn.
function scr_bot_play_turn(_depth) {
    if (global.game_over || global.pending_promotion != noone) return;

    var _color = global.turn;
    var _move = scr_bot_choose_move(_color, _depth);
    if (_move == noone) return; // scr_check_game_end already caught this case

    if (_move.kind == "move") {
        scr_make_move(_move.fr, _move.fc, _move.tr, _move.tc);
        if (global.pending_promotion != noone) scr_bot_choose_promotion();
    } else {
        scr_make_drop(_move.type, _color, _move.r, _move.c);
    }
}
