if (global.game_over) exit;
if (global.pending_promotion != noone) exit;
if (global.turn != global.bot_color) exit;

// Do not move while the speech bubble is visible. Recheck shortly; the
// obj_rook Step event counts the timer down and clears the message at zero.
if (variable_global_exists("rook_speech_timer")
    && variable_global_exists("rook_speech_text")
    && global.rook_speech_timer > 0
    && global.rook_speech_text != "") {
    alarm[0] = max(1, ceil(room_speed * 0.1));
    exit;
}

show_debug_message("[Rook debug] Alarm 0 fired. Calling scr_bot_play_turn().");
show_debug_message("[Rook debug] turn=" + string(global.turn)
    + " bot_color=" + string(global.bot_color)
    + " depth=" + string(global.bot_depth));

var _turn_before = global.turn;
scr_bot_play_turn(global.bot_depth);

show_debug_message("[Rook debug] Bot function returned. turn="
    + string(global.turn) + " game_over=" + string(global.game_over));

if (!global.game_over && global.turn == _turn_before) {
    show_debug_message("[Rook debug] WARNING: scr_bot_play_turn returned without changing the turn. Check that script's move selection/application logic.");
}