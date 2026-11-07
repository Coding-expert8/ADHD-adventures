if (id == global.controller_instance) {
	// draw state carries over from the room before (the help screen leaves its fade-in alpha set),
	// and the GUI size follows the window, so set both here and lay out in this room's 1366x768 units
	var _s = display_get_gui_height() / room_height
	matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _s, _s, 1))
	draw_set_alpha(1)
	draw_set_font(fnt_default)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_text(50, 600, global.questions[global.current_q])
	draw_text(50, 630, "Answer: " + global.word_input)
	if (global.round_time > 0) {
		draw_text(50, 690, "Time: " + string(global.round_timer div 60))
	}
	matrix_set(matrix_world, matrix_build_identity())
}