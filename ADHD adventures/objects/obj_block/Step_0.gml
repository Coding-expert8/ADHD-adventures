if (can_fall) {
	if (y < 350) {
		y += 2.5
	} else {
		is_landed = true
	}
}

if (collapse_timer > 0) {
	collapse_timer -= 1
	image_blend = merge_color(c_white, c_red, 1 - (collapse_timer / 60))
	if (collapse_timer <= 0) {
		is_landed = false
		instance_deactivate_object(id)
		alarm[1] = 1
	}
}

if (!instance_exists(global.controller_instance)) {
	global.controller_instance = id
}

if (id == global.controller_instance) {

	// --- ADDED: pause state setup + gate ---
	if (!variable_global_exists("paused")) global.paused = false
	if (!variable_global_exists("pause_timer")) global.pause_timer = 0
	if (!variable_global_exists("rounds_passed")) global.rounds_passed = 0

	if (global.paused) {
		global.pause_timer -= 1
		if (global.pause_timer <= 0) {
			global.paused = false
		}
	} else {

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

	global.rounds_passed += 1
		if (global.rounds_passed > 2) {
			var _collapse_count = irandom_range(2,4)
			var _landed_blocks = []
			with (obj_block) {
				if (is_landed && collapse_timer == -1) {
					array_push(_landed_blocks, id)
				}
			}
			var _available = array_length(_landed_blocks)
			if (_available > 0) {
				repeat (min(_collapse_count, _available)) {
					var _pick = irandom(array_length(_landed_blocks) - 1)
					var _target = _landed_blocks[_pick]
					if (instance_exists(_target)) {
						_target.collapse_timer = 60
					}
					array_delete(_landed_blocks, _pick, 1)
				}
			}
		}

	global.paused = true
		global.pause_timer = 120
	}

	}
}