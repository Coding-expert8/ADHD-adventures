if (can_fall) {
	if y < 600 {
		y = y+4
	}
}

// --- Re-elect controller every frame if the current one no longer exists ---
if (!instance_exists(global.controller_instance)) {
	global.controller_instance = id
}

if (id == global.controller_instance) {

	var _key = keyboard_lastchar
	if (_key != "" && string_length(global.word_input) < 30) {
		if (string_lower(_key) != string_upper(_key)) {
			global.word_input += _key
		}
		keyboard_lastchar = ""
	}

	if (keyboard_check_pressed(vk_backspace) && string_length(global.word_input) > 0) {
		global.word_input = string_delete(global.word_input, string_length(global.word_input), 1)
	}

	var _should_submit = false

	if (global.round_time > 0) {
		global.round_timer -= 1
		if (global.round_timer <= 0) {
			_should_submit = true
		}
	}

	if (keyboard_check_pressed(vk_enter)) {
		_should_submit = true
	}

	if (_should_submit) {

		var _word_clean = string_lower(string_replace_all(global.word_input, " ", ""))
		var _valid_answers = global.answers[global.current_q]
		var _is_correct = false

		for (var j = 0; j < array_length(_valid_answers); j++) {
			if (_word_clean == _valid_answers[j]) {
				_is_correct = true
				break
			}
		}

if (_is_correct) {
	var _letters = string_length(global.word_input)
	var i = 1
	repeat (_letters) {
		var _inst = instance_create_layer(spawn_x + global.spacing, spawn_y, "Instances", obj_block)
		_inst.can_fall = false
		_inst.alarm[0] = i * 10
		global.spacing = global.spacing + 16
		i += 1
	}
}

		global.current_q += 1
		if (global.current_q >= array_length(global.questions)) global.current_q = 0
		global.word_input = ""
		global.round_timer = global.round_time
	}
}