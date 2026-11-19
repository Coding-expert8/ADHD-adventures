// Walk up to the key and press Q to pick it up (same key and range check as talking to an NPC).
if (!keyboard_check_pressed(ord("Q"))) exit;
if (variable_global_exists("dialogue_npc") and instance_exists(global.dialogue_npc)) exit; // Q is advancing dialogue
if (instance_exists(obj_login) and obj_login.popup_open) exit;                            // Q is just a letter while typing a name
if (!instance_exists(obj_player) or distance_to_object(obj_player) > pickup_range) exit;

// picked up: one more key towards the boss, one fewer waiting to be collected
global.key_count += 1;
global.keys_pending = max(0, global.keys_pending - 1);
save_game();
keyboard_clear(ord("Q")); // consume the press so an NPC in range doesn't also react to it
instance_destroy();
