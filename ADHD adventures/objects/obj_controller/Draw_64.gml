if (room == room_answer && waiting_for_word) {
	draw_set_font(fnt_default) 	draw_set_color(c_black)
	draw_set_halign(fa_left)

	draw_text(200, 50, "Type a word with at least " + string(min_word_length) + " letters!")
	draw_text(50, 80, "Word: " + word_input)

	if (round_time > 0) {
		draw_text(50, 110, "Time: " + string(round_timer div 60))
	}
}