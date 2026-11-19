/// Room transitions, played with the sequences seq_fade_out and seq_fade_in.
/// transition_to(room) fades the screen to black, changes room, then fades back in.
/// The fade is drawn on a layer, so Draw GUI things (like the map's hearts) stay on top of it.
/// Currently used for entering and leaving the fishing game only.
function transition_to(_room) {
	if (instance_exists(obj_transition)) return; // one at a time
	var _t = instance_create_depth(0, 0, 0, obj_transition);
	_t.target_room = _room;
}

/// True while a fade is playing; use it to ignore input during the transition.
function transition_active() {
	return instance_exists(obj_transition);
}
