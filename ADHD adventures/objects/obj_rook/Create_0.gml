if (!variable_global_exists("bot_color")) {
    global.bot_color = 1 - COLOR_WHITE;
}
 
// Keep your existing difficulty setting if it has already been configured.
if (!variable_global_exists("bot_depth")) {
    global.bot_depth = 3;
}
 
 wait = 3;
 
// Delay before Rook moves, measured in game steps.
rook_delay_frames = max(1, round(room_speed * 0.45));
 
// GUI coordinates for the 1272x712 screenshot supplied with this request.
// Change these values if your GUI size or board position changes.
rook_sprite_x = 1100;
rook_sprite_y = 535;
rook_sprite_scale = 0.48;
 
rook_bubble_x = 840;
rook_bubble_y = 155;
rook_bubble_w = 365;
rook_bubble_h = 185;
 
// The Step event takes its first board snapshot after obj_tinyhouse has
// completed its Create event, so object creation order does not matter.
rook_ready = false;
rook_seen_turn = -1;
rook_seen_signature = "";
rook_seen_hand_total = 0;
rook_seen_board_count = 0;
rook_pending_actor = -1;
rook_pending_hand_before = 0;
rook_pending_board_before = 0;

global.rook_speech_text = "Ah, a challenger. Let's begin.";
global.rook_speech_timer = ceil(room_speed * wait); // Five seconds to read the opening line.