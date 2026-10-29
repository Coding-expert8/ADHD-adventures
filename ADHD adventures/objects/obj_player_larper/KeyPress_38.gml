if (_up) and (jumped == false) {
	motion_set(image_angle + 90, jump);
	if not place_meeting(x, y, obj_platform) {
		jumped = true;
	}
}