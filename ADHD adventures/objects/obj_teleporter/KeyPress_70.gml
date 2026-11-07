if (room == room_answer) exit; // letters are typed as answers in the falling-blocks game
if full_screen == false {
	window_set_fullscreen(true);
	full_screen = true;
}
else {
	window_set_fullscreen(false);
	full_screen = false;
}
	