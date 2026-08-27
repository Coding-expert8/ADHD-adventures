if (falling_in) {
	y += fall_spd
	if (y >= target_y) {
		y = target_y
		falling_in = false
	}
	exit
}

if (!is_active) {
	y += 6
	image_alpha -= 0.03
	if (image_alpha <= 0) instance_destroy()
	exit
}

if (collapse_timer > 0) {
	collapse_timer -= 1
	image_blend = merge_color(c_white, c_red, 1 - (collapse_timer / 60))
	if (collapse_timer <= 0) {
		is_active = false
		instance_deactivate_object(id)
	}
}