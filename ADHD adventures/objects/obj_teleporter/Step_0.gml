if (global.goto_place) {
	if room = room_map {
		with (obj_player) {
			x = global.place_x;
			y = global.place_y;
			global.goto_place = false;
		}
	}
}