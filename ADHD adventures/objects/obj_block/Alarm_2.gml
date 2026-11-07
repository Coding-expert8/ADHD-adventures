var _removed = 0
var _skipped = []

while (_removed < global.collapse_chunk_size && ds_list_size(global.block_order) > 0) {
	var _oldest = global.block_order[| 0]
	ds_list_delete(global.block_order, 0)

	if (instance_exists(_oldest) && _oldest.is_landed && _oldest.collapse_timer == -1) {

		if (_oldest == global.controller_instance) {
			var _new_controller = noone
			with (obj_block) {
				if (id != _oldest && instance_exists(id)) {
					_new_controller = id
					break
				}
			}
			if (_new_controller != noone) {
				global.controller_instance = _new_controller
			}
		}

		_oldest.collapse_timer = 60
		_removed += 1

	} else if (instance_exists(_oldest)) {
		array_push(_skipped, _oldest)
	}
}

for (var k = 0; k < array_length(_skipped); k++) {
	ds_list_add(global.block_order, _skipped[k])
}

global.collapse_chunk_size += 2