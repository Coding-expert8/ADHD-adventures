// Game progress and the save file (save.ini), plus the player's settings (settings.ini).
//
// The code at the bottom of this script runs once when the game starts, before the first room,
// so every progress global exists from the very first frame. obj_save (placed in room_start)
// then loads save.ini over these defaults.
//
// save.ini is written to the game's save folder (on Windows: %LOCALAPPDATA%\<game name>\save.ini).
// It is saved: on every arrival on room_map, when the player enters their name (obj_login),
// when F5 is pressed, and when the game closes (obj_save).
//
// settings.ini (volumes, fullscreen) is a separate file, so deleting the save or losing all
// hearts starts a new game without throwing away the player's settings.

#macro SAVE_FILE     "save.ini"
#macro SETTINGS_FILE "settings.ini"
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
	ini_write_real("Player", "Coins", global.coin);
	ini_write_real("Player", "PlayTime", global.play_time);

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

	// The game was closed during "You died": that run is over, so start a new game
	// instead of loading the old progress back with full hearts.
	if (ini_read_real("Player", "Hearts", HEARTS_MAX) <= 0) {
		ini_close();
		reset_save();
		return false;
	}

	global.username = ini_read_string("Player", "Name", global.username);

	var _char = ini_read_string("Player", "Character", global.save_character);
	if (_char == "1" or _char == "2" or _char == "3" or _char == "4" or _char == "5" or _char == "6") {
		global.save_character = _char;
	}
	global.character = global.save_character;

	global.hearts = ini_read_real("Player", "Hearts", global.hearts);
	global.key_count = ini_read_real("Player", "Keys", global.key_count);
	global.keys_pending = ini_read_real("Player", "KeysToCollect", global.keys_pending);
	global.coin = ini_read_real("Player", "Coins", global.coin);
	global.play_time = ini_read_real("Player", "PlayTime", global.play_time);

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

/// @func new_game_state()
/// @desc Sets every progress global to its new-game value. Runs at game start (bottom of this
///       script) and again from reset_save().
function new_game_state() {
	for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
		variable_global_set(global.beaten_flags[_i], false);
	}

	global.hearts           = HEARTS_MAX;
	global.key_count        = 0;
	global.keys_pending     = 0;     // keys won but not picked up yet (obj_player drops them on the map)
	global.coin             = 0;     // shop money (obj_shop)
	global.play_time        = 0;     // seconds played on this save (counted by obj_save)
	global.minigame_leaving = false; // true from minigame_win() until room_map starts
	global.last_minigame_room = noone;     // room the last minigame portal led to (obj_minigame_portal)
	global.boss_message_pending = false;   // all six just beaten: that NPC says to go fight the boss
	global.username         = "";    // set by obj_login (an empty name shows the name popup again)
	global.save_character   = "1";   // obj_player copies this into global.character when it first starts
	global.character        = "1";
	global.discovered_areas = {};    // area_name -> true, filled by obj_area_control (see scr_teleport)
	global.return_x         = undefined; // no saved map position: obj_player starts at its room spot
	global.return_y         = undefined;
	global.goto_place       = false;
	global.respawn_village  = false; // true: obj_player starts room_map on the village teleport point
}

/// @func reset_save()
/// @desc Wipes the whole save: deletes save.ini and puts every progress global back to its
///       new-game value. Used when the player loses all their hearts and by the DELETE SAVE
///       button (pause menu, STATS tab). Settings (settings.ini) are kept.
///       Call restart_on_map() afterwards to begin the new game.
function reset_save() {
	if (file_exists(SAVE_FILE)) file_delete(SAVE_FILE);
	new_game_state();
	global.respawn_village = true;
}

/// @func restart_on_map()
/// @desc Starts room_map fresh (after reset_save the player stands in the village).
function restart_on_map() {
	if (room == room_map) room_restart();
	else room_goto(room_map);
}

/// @func minigame_win(flag, [delay_seconds])
/// @desc Call when the player wins a minigame, e.g. minigame_win("fishing_beaten").
///       Sets that *_beaten flag (opening its gates), gives a key the first time the game is
///       beaten (obj_player drops it next to the player on the map), and fades back to room_map
///       after delay_seconds (time to read a "You win!" screen). Safe to call every step.
function minigame_win(_flag, _delay = 0) {
	if (global.minigame_leaving) return;   // already on the way back to the map
	global.minigame_leaving = true;

	var _first = !variable_global_get(_flag);
	if (_first) global.keys_pending += 1;   // first win only
	variable_global_set(_flag, true);

	// that was the last of the six: the NPC who sent the player here points them to the boss
	// (obj_npc, using global.last_minigame_room) once they are back on the map
	if (_first and beaten_count() == array_length(global.beaten_flags)) global.boss_message_pending = true;

	if (_delay <= 0) transition_to(room_map);
	else call_later(_delay, time_source_units_seconds, function() {
		if (global.minigame_leaving) transition_to(room_map);   // unless already back on the map
	});
}

/// @func beaten_count()
/// @desc How many of the six minigames have been beaten (the lit pills on obj_boss_pad).
function beaten_count() {
	var _n = 0;
	for (var _i = 0; _i < array_length(global.beaten_flags); _i++) {
		if (variable_global_get(global.beaten_flags[_i])) _n += 1;
	}
	return _n;
}

/// @func typing_name()
/// @desc True while the player is typing in the name popup (obj_login). Letter and number
///       hotkeys check this so typing a name doesn't also trigger them.
function typing_name() {
	return instance_exists(obj_login) and obj_login.popup_open and obj_login.input_active;
}

/// @func pause_menu_open()
/// @desc True while the PAUSE or CREDITS board or the shop is open (the pause screen). The
///       player stands still and the other menu buttons can't be opened underneath it.
///       (Not called menu_open: obj_shop has an instance variable with that name, and a
///       script function would hide it.)
function pause_menu_open() {
	return (instance_exists(obj_help) and obj_help.help_open)
		or (instance_exists(obj_credits) and obj_credits.credits_open)
		or (instance_exists(obj_shop) and obj_shop.menu_open);
}

/// @func menu_board_scale()
/// @desc Scale for the PAUSE and CREDITS boards: they are laid out for a MENU_BOARD_HEIGHT px
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

/// @func format_play_time(seconds)
/// @desc "1:05:09" or "5:09"
function format_play_time(_secs) {
	_secs = floor(_secs);
	var _h = _secs div 3600;
	var _m = (_secs div 60) mod 60;
	var _s = _secs mod 60;
	var _ss = (_s < 10 ? "0" : "") + string(_s);
	if (_h > 0) return string(_h) + ":" + (_m < 10 ? "0" : "") + string(_m) + ":" + _ss;
	return string(_m) + ":" + _ss;
}

// ---- settings (settings.ini) ----

/// @func settings_load()
/// @desc Reads settings.ini into global.settings (defaults when there is no file yet).
function settings_load() {
	global.settings = { master: 1, music: 1, sfx: 1, fullscreen: false };
	if (!file_exists(SETTINGS_FILE)) return;
	ini_open(SETTINGS_FILE);
	global.settings.master     = clamp(ini_read_real("Audio", "Master", 1), 0, 1);
	global.settings.music      = clamp(ini_read_real("Audio", "Music", 1), 0, 1);
	global.settings.sfx        = clamp(ini_read_real("Audio", "SFX", 1), 0, 1);
	global.settings.fullscreen = ini_read_real("Display", "Fullscreen", 0) == 1;
	ini_close();
}

/// @func settings_save()
function settings_save() {
	ini_open(SETTINGS_FILE);
	ini_write_real("Audio", "Master", global.settings.master);
	ini_write_real("Audio", "Music", global.settings.music);
	ini_write_real("Audio", "SFX", global.settings.sfx);
	ini_write_real("Display", "Fullscreen", global.settings.fullscreen ? 1 : 0);
	ini_close();
}

/// @func settings_apply_audio()
/// @desc Sets the master volume, and the volume of every music and sound-effect asset.
///       A sound's final volume is master x asset x the volume it was played with, so code that
///       plays or fades sounds at volume 1 still follows these settings.
function settings_apply_audio() {
	audio_master_gain(global.settings.master);

	var _sounds = asset_get_ids(asset_sound);
	for (var _i = 0; _i < array_length(_sounds); _i++) {
		var _snd = _sounds[_i];
		if (sound_is_music(_snd)) {
			// leave a theme alone while obj_area_control is fading it out (it stops it after)
			if (instance_exists(obj_area_control) and obj_area_control.fade_snd == _snd) continue;
			audio_sound_gain(_snd, global.settings.music, 0);
		} else {
			audio_sound_gain(_snd, global.settings.sfx, 0);
		}
	}
}

/// @func sound_is_music(sound)
/// @desc Music is every mus_* asset plus the victory jingle; everything else is a sound effect.
function sound_is_music(_snd) {
	var _name = audio_get_name(_snd);
	return string_starts_with(_name, "mus_") or _name == "_1_46__Victory_Against_Gym_Leader_";
}

/// @func settings_set_fullscreen(on)
function settings_set_fullscreen(_on) {
	global.settings.fullscreen = _on;
	window_set_fullscreen(_on);
	settings_save();
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
// display names for the pause menu's STATS tab, in the same order as beaten_flags
global.beaten_names = ["Chess", "Snake", "Fishing", "Ice Rocks", "Lava Parkour", "Bridge"];

new_game_state();
settings_load();   // applied by obj_save when the first room starts
