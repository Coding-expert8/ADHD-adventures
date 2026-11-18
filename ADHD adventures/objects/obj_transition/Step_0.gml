if (seq == -1) exit;

cover_screen();

if (layer_sequence_is_finished(seq)) {
	if (fading_out) {
		// Screen is black: change room. Room Start plays the fade-in.
		// (The layer is removed along with the old room.)
		fading_out = false;
		seq = -1;
		room_goto(target_room);
	}
	else {
		layer_destroy(seq_layer);
		instance_destroy();
	}
}
