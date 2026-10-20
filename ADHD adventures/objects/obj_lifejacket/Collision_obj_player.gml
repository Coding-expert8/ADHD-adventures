other.is_dead = false

var target_block = noone

if (ds_list_size(global.block_order) > 0) {
	target_block = global.block_order[| ds_list_size(global.block_order) - 1]
}

if (target_block != noone && instance_exists(target_block)) {
	other.x = target_block.x
	other.float_target_y = target_block.y - 104
} else {
	other.float_target_y = other.y
}

other.floating_up = true

instance_destroy(id)