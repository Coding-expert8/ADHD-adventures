// Created by transition_to(room). Persistent, so it survives the room change:
// fade out here -> room_goto -> fade in on Room Start -> destroy itself.
target_room = room; // set by transition_to() right after creation
fading_out = true;
seq_layer = -1;
seq = -1;

// Play a fade sequence on its own top layer, stretched over the visible screen.
// The sequences draw an 8x8 white pixel sprite, so scale = screen size / 8.
play_fade = function(_sequence) {
	seq_layer = layer_create(-15000, "Transition");
	seq = layer_sequence_create(seq_layer, 0, 0, _sequence);
	cover_screen();
}

// Keep the fade over the camera (the map camera can still move while fading out)
cover_screen = function() {
	var _x = 0;
	var _y = 0;
	var _w = room_width;
	var _h = room_height;
	if (view_enabled and view_visible[0]) {
		var _cam = view_camera[0];
		_x = camera_get_view_x(_cam);
		_y = camera_get_view_y(_cam);
		_w = camera_get_view_width(_cam);
		_h = camera_get_view_height(_cam);
	}
	layer_sequence_x(seq, _x);
	layer_sequence_y(seq, _y);
	layer_sequence_xscale(seq, _w / 8);
	layer_sequence_yscale(seq, _h / 8);
}

play_fade(seq_fade_out);
