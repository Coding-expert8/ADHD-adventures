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
	ini_write_real("Player", "KeysToCollect", global.keys_pending);

	for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
		var _flag = global.beaten_flags[_i];
		ini_write_real("Progress", _flag, variable_global_get(_flag) ? 1 : 0);
	}
	ini_write_string("Progress", "discovered_areas", discovered_areas_to_string());

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
	global.keys_pending = ini_read_real("Player", "KeysToCollect", global.keys_pending);

	for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
		var _flag = global.beaten_flags[_i];
		variable_global_set(_flag, ini_read_real("Progress", _flag, 0) == 1);
	}
	discovered_areas_from_string(ini_read_string("Progress", "discovered_areas", ""));

	// obj_player's Room Start puts the player here when room_map starts
	if (ini_key_exists("Map", "X") and ini_key_exists("Map", "Y")) {
		global.return_x = ini_read_real("Map", "X", 0);
		global.return_y = ini_read_real("Map", "Y", 0);
	}

	ini_close();
	return true;
}

/// @func minigame_win(flag, [delay_seconds])
/// @desc Call when the player wins a minigame, e.g. minigame_win("fishing_beaten").
///       Sets that *_beaten flag (opening its gates), gives a key the first time the game is
///       beaten (obj_player drops it next to the player on the map), and fades back to room_map
///       after delay_seconds (time to read a "You win!" screen). Safe to call every step.
function minigame_win(_flag, _delay = 0) {
	if (global.minigame_leaving) return;   // already on the way back to the map
	global.minigame_leaving = true;

	if (!variable_global_get(_flag)) global.keys_pending += 1;   // first win only
	variable_global_set(_flag, true);

	if (_delay <= 0) transition_to(room_map);
	else call_later(_delay, time_source_units_seconds, function() {
		if (global.minigame_leaving) transition_to(room_map);   // unless already back on the map
	});
}

/// @func typing_name()
/// @desc True while the player is typing in the name popup (obj_login). Letter and number
///       hotkeys check this so typing a name doesn't also trigger them.
function typing_name() {
	return instance_exists(obj_login) and obj_login.popup_open and obj_login.input_active;
}

/// @func pause_menu_open()
/// @desc True while the HELP or CREDITS board or the shop is open (the pause screen). The
///       player stands still and the other menu buttons can't be opened underneath it.
///       (Not called menu_open: obj_shop has an instance variable with that name, and a
///       script function would hide it.)
function pause_menu_open() {
	return (instance_exists(obj_help) and obj_help.help_open)
		or (instance_exists(obj_credits) and obj_credits.credits_open)
		or (instance_exists(obj_shop) and obj_shop.menu_open);
}

/// @func menu_board_scale()
/// @desc Scale for the HELP and CREDITS boards: they are laid out for a MENU_BOARD_HEIGHT px
///       tall GUI and drawn (and clicked) scaled up to the real GUI height.
#macro MENU_BOARD_HEIGHT 480
function menu_board_scale() {
	return max(1, display_get_gui_height() / MENU_BOARD_HEIGHT);
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
global.keys_pending   = 0;     // keys won but not picked up yet (obj_player drops them on the map)
global.minigame_leaving = false; // true from minigame_win() until room_map starts
global.username       = "";    // set by obj_login
global.save_character = "1";   // obj_player copies this into global.character when it first starts
global.discovered_areas = {};  // area_name -> true, filled by obj_area_control (see scr_teleport)
