audio_stop_all();
audio_play_sound(snd_car_crash, 1, false);
instance_destroy();
repeat(10)
	{
		instance_create_layer(x, y, "Instances", obj_debris);
	}

lives -= 1

with (obj_game_space_rocks)
{
	alarm[1] = room_speed;
}
