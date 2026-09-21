var l7A82C1F2_0 = false;l7A82C1F2_0 = instance_exists(obj_arena_shooter_player);if(l7A82C1F2_0){	direction = point_direction(x, y, obj_player.x, obj_player.y);

	speed = spd;}

image_angle = direction;

if(hp <= 0){	with(obj_score) {
	thescore += 5;
	
	}

	audio_sound_pitch(snd_death, random_range(0.8, 1.2));

	audio_play_sound(snd_death, 0, 0, 1.0, undefined, 1.0);

	instance_destroy();}