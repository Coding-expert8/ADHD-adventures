if selected_slot = 1 and hotbar_items[0].cooldown_remaining <= 0 {
	instance_create_layer(x,y,"Instances",obj_brake_space_rocks);
}
if selected_slot = 3 and hotbar_items[2].cooldown_remaining <= 0 {
	with (obj_ship) {
		repeat (10) {
			var inst = instance_create_layer(x, y, "Instances", obj_bullet);
			inst.direction = image_angle;
			inst.image_index = 1;
		}
		global.shots_fired += 10;
		audio_play_sound(sound_loud_shot, 1, false);
	}
}

if selected_slot = 4 and hotbar_items[3].cooldown_remaining <= 0 {
	with (obj_ship) {
		audio_play_sound(snd_engine, 1, true);
		pace = 0.05 * 5;
		alarm[3] = 300;
	}
}

if selected_slot = 5 and hotbar_items[4].cooldown_remaining <= 0 {
	compass_arrow_active = true;
	if (!compass_changed) {
		alarm[2] = 300;
		compass_changed = true;
	}
}

if selected_slot = 6 and hotbar_items[5].cooldown_remaining <= 0 {
	map_open = !map_open;
	if (map_open) {
		audio_play_sound(snd_paper_scroll,1,false);
	}
}