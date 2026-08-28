if (waiting_for_word) {
	var _key = keyboard_lastchar

	if (_key != "" && string_length(word_input) < 30) {
		if (string_lower(_key) != string_upper(_key)) {
			word_input += _key
		}
		keyboard_lastchar = ""
	}

	if (keyboard_check_pressed(vk_backspace) && string_length(word_input) > 0) {
		word_input = string_delete(word_input, string_length(word_input), 1)
	}

	if (round_time > 0) {
		round_timer -= 1
		if (round_timer <= 0) {
			submit_word()
		}
	}

	if (keyboard_check_pressed(vk_enter)) {
		submit_word()
	}
}