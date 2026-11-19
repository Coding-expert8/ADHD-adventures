if (global.game_over) exit;
if (global.pending_promotion != noone) exit;
if (global.turn != global.bot_color) exit;
 
// Reuse the bot/rules engine already in your Tinyhouse project.
scr_bot_play_turn(global.bot_depth);