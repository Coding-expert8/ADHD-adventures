// The minigame flags (global.*_beaten) are declared at game start and loaded from save.ini
// in scr_save, so a key appearing must not reset them.
if (!variable_global_exists("key_count")) global.key_count = 0;

pickup_range = 24; // px between the player's feet and the pill for Q to pick it up
