// Name entry popup on room_map. global.username is declared in scr_save and loaded from
// save.ini, so the popup only shows until the player has entered a name once.
username_input = global.username;
input_active = false;
popup_open = (global.username == "");

keyboard_string = "";
