if lives <= 0 {
	global.hearts -= 1;
	room_goto(room_map);
}