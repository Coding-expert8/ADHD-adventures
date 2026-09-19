if (!variable_global_exists("collapse_chunk_size"))
global.collapse_chunk_size = 4

var _removed = 0
while (_removed < global.collapse_chunk_size && ds_list_size(global.block_order) > 0) {
	var _oldest = global.block_order[| 0]
	ds_list_delete(global.block_order, 0)

	if (instance_exists(_oldest) && _oldest.is_landed && _oldest.collapse_timer == -1) {
		_oldest.collapse_timer = 60
		_removed += 1
	}
}

global.collapse_chunk_size += 2