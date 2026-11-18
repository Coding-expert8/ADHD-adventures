if (global.can_fire)
{
	var inst = instance_create_layer(x, y, "Instances", obj_bullet);
	inst.direction = image_angle;

	alarm[0] = 2 * room_speed;


	global.shots_fired++;
	audio_play_sound(snd_shoot,1,false);
}
