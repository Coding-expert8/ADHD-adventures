instance_destroy();
repeat(10)
	{
		instance_create_layer(x, y, "Instances", obj_debris);
	}

lives -= 1

<<<<<<< HEAD
with (obj_game)
=======
with (obj_game_space_rocks)
>>>>>>> Tiny_house_branch
{
	alarm[1] = room_speed;
}
