block_spacing = 64
bridge_start_x = 100
bridge_y = 200
blocks_placed = 0
block_list = ds_list_create()
min_word_length = 3
word_input = ""
waiting_for_word = true
round_time = 300
round_timer = round_time

function spawn_block() {
	var _x = bridge_start_x + (blocks_placed * block_spacing)
	var _inst = instance_create_layer(_x, bridge_y - 400, "Instances", obj_block)
	_inst.target_y = bridge_y
	ds_list_add(block_list, _inst)
	blocks_placed += 1
}

function random_collapse() {
	var _count = irandom_range(1, 2)
	repeat (_count) {
		if (ds_list_size(block_list) > 0) {
			var _index = irandom(ds_list_size(block_list) - 1)
			var _block = block_list[| _index]
			if (instance_exists(_block) && _block.is_active) {
				_block.collapse_timer = 60
			}
		}
	}
}

function submit_word() {
	var _len = string_length(word_input)
	if (_len >= min_word_length) {
		spawn_block()
		min_word_length += 1
	} else {
		random_collapse()
	}
	random_collapse()
	word_input = ""
	round_timer = round_time
}

spawn_block()