if (typing_name()) exit; // the key is a letter in the name popup (obj_login)
if (room == room_answer) exit; // letters are typed as answers in the falling-blocks game
// F: toggle fullscreen (same setting as the pause menu's SETTINGS tab, saved in settings.ini)
settings_set_fullscreen(!global.settings.fullscreen);
