if (id == global.controller_instance) {
	draw_set_color(c_white)
	draw_text(50, 600, global.questions[global.current_q])
	draw_text(50, 630, "Answer: " + global.word_input)
	if (global.round_time > 0) {
		draw_text(50, 690, "Time: " + string(global.round_timer div 60))
	}
}