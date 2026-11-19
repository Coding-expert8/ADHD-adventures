if (!rook_ready) {
    if (!variable_global_exists("board")
        || !variable_global_exists("hand")
        || !variable_global_exists("turn")) {
        exit;
    }

    rook_seen_turn = global.turn;
    rook_seen_signature = scr_rook_board_signature();
    rook_seen_hand_total = scr_rook_hand_total();
    rook_seen_board_count = scr_rook_board_count();
    rook_pending_actor = -1;
    rook_pending_hand_before = rook_seen_hand_total;
    rook_pending_board_before = rook_seen_board_count;
    rook_ready = true;
}

// Count down the current speech. Text is cleared only when its five seconds end.
if (global.rook_speech_timer > 0) {
    global.rook_speech_timer -= 1;
    if (global.rook_speech_timer <= 0) {
        global.rook_speech_timer = 0;
        global.rook_speech_text = "";
    }
}

var _now_signature = scr_rook_board_signature();
var _now_hand_total = scr_rook_hand_total();
var _now_board_count = scr_rook_board_count();

// Detect a completed board move, drop or capture.
if (rook_pending_actor == -1
    && (global.turn != rook_seen_turn || _now_signature != rook_seen_signature)) {
    rook_pending_actor = rook_seen_turn;
    rook_pending_hand_before = rook_seen_hand_total;
    rook_pending_board_before = rook_seen_board_count;
}

// If promotion is pending, wait until the promoting player chooses a piece.
if (rook_pending_actor != -1 && global.pending_promotion == noone) {
    var _captured = (_now_hand_total > rook_pending_hand_before)
        || (_now_board_count < rook_pending_board_before);
    var _checked_side = -1;

    if (!global.game_over && scr_in_check(global.turn)) {
        _checked_side = global.turn;
    }

    scr_rook_react(rook_pending_actor, _captured, _checked_side);
    rook_pending_actor = -1;
}

rook_seen_turn = global.turn;
rook_seen_signature = _now_signature;
rook_seen_hand_total = _now_hand_total;
rook_seen_board_count = _now_board_count;

// Deduct exactly one heart if Rook (the bot) wins. The flag prevents repeated
// deductions while global.game_over remains true for subsequent frames.
if (global.game_over
    && global.winner == global.bot_color
    && !global.rook_heart_penalty_applied) {

    if (variable_global_exists("hearts")) {
        global.hearts = max(0, global.hearts - 1);
        show_debug_message("[Rook] Player lost. Hearts remaining: " + string(global.hearts));
    } else {
        show_debug_message("[Rook] WARNING: global.hearts does not exist; no heart could be deducted.");
    }

    global.rook_heart_penalty_applied = true;
}