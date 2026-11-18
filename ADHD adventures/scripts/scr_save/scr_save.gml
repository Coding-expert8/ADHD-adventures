// Game progress and the save file (save.ini).
//
// The code at the bottom of this script runs once when the game starts, before the first room,
// so every progress global exists from the very first frame. obj_save (placed in room_start)
// then loads save.ini over these defaults.
//
// save.ini is written to the game's save folder (on Windows: %LOCALAPPDATA%\<game name>\save.ini).
// It is saved: on every arrival on room_map, when the player enters their name (obj_login),
// when F5 is pressed, and when the game closes (obj_save).

#macro SAVE_FILE  "save.ini"
#macro HEARTS_MAX 6   // overworld hearts, in halves (6 = 3 full hearts)

/// @func save_game()
/// @desc Writes all progress to save.ini. The map position is only updated while on room_map,
///       so saving inside a minigame keeps the spot the player left the map from.
function save_game() {
	ini_open(SAVE_FILE);

	ini_write_string("Player", "Name", global.username);
	ini_write_string("Player", "Character", variable_global_exists("character") ? global.character : global.save_character);
	ini_write_real("Player", "Hearts", global.hearts);
	ini_write_real("Player", "Keys", global.key_count);

	for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
		var _flag = global.beaten_flags[_i];
		ini_write_real("Progress", _flag, variable_global_get(_flag) ? 1 : 0);
	}

	if (room == room_map and instance_exists(obj_player)) {
		ini_write_real("Map", "X", obj_player.x);
		ini_write_real("Map", "Y", obj_player.y);
	}

	ini_close();
}

/// @func load_game()
/// @desc Reads save.ini over the defaults below. Returns false when there is no save yet.
function load_game() {
	if (!file_exists(SAVE_FILE)) return false;
	ini_open(SAVE_FILE);

	global.username = ini_read_string("Player", "Name", global.username);

	var _char = ini_read_string("Player", "Character", global.save_character);
	if (_char == "1" or _char == "2" or _char == "3" or _char == "4" or _char == "5" or _char == "6") {
		global.save_character = _char;
	}

	global.hearts = ini_read_real("Player", "Hearts", global.hearts);
	if (global.hearts <= 0) global.hearts = HEARTS_MAX;   // never load straight into "You died"
	global.key_count = ini_read_real("Player", "Keys", global.key_count);

	for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
		var _flag = global.beaten_flags[_i];
		variable_global_set(_flag, ini_read_real("Progress", _flag, 0) == 1);
	}

	// obj_player's Room Start puts the player here when room_map starts
	if (ini_key_exists("Map", "X") and ini_key_exists("Map", "Y")) {
		global.return_x = ini_read_real("Map", "X", 0);
		global.return_y = ini_read_real("Map", "Y", 0);
	}

	ini_close();
	return true;
}

/// @func typing_name()
/// @desc True while the player is typing in the name popup (obj_login). Letter and number
///       hotkeys check this so typing a name doesn't also trigger them.
function typing_name() {
	return instance_exists(obj_login) and obj_login.popup_open and obj_login.input_active;
}

/// @func menu_open()
/// @desc True while the HELP or CREDITS board is open (the pause screen). The player
///       stands still and the other menu button can't be opened underneath it.
function menu_open() {
	return (instance_exists(obj_help) and obj_help.help_open)
		or (instance_exists(obj_credits) and obj_credits.credits_open);
}

/// @func play_select()
/// @desc Click sound for menu buttons.
function play_select() {
	audio_play_sound(snd_select, 1, false);
}

// ---- runs at game start: every progress global, with its new-game value ----

// One flag (and one key) per minigame. A gate on room_map opens when its flag is true
// (obj_gate: unlock = "<flag name>").
global.beaten_flags = [
	"tinyhouse_beaten",     // chess (town)
	"snake_beaten",         // snake (desert)
	"fishing_beaten",       // fishing (lake)
	"space_rocks_beaten",   // ice rocks (ice)
	"lava_parkour_beaten",  // lava parkour (lava)
	"bridge_beaten",        // bridge crossing (river)
];
for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
	variable_global_set(global.beaten_flags[_i], false);
}

global.hearts         = HEARTS_MAX;
global.key_count      = 0;
global.username       = "";    // set by obj_login
global.save_character = "1";   // obj_player copies this into global.character when it first starts
