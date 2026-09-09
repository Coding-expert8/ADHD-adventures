if (id == global.controller_instance) {
	draw_set_color(c_white)
	draw_text(50, 400, global.questions[global.current_q])
	draw_text(50, 430, "Answer: " + global.word_input)
	if (global.round_time > 0) {
		draw_text(50, 460, "Time: " + string(global.round_timer div 60))
	}
}