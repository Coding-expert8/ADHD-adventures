// Loads save.ini once, when the game starts (placed in room_start, persistent).
// The globals it fills in are declared, with new-game values, in scr_save.
if (instance_number(obj_save) > 1)
{
	// room_start was entered again: the first obj_save is still running, so don't reload
	instance_destroy();
	exit;
}

load_game();

saved_timer = 0;   // steps left to show "Game saved" after pressing F5
