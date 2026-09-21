if (variable_global_exists("spawn_id"))
{
	with (obj_spawn)
	{
		if (spawn_id == global.spawn_id)
		{
			other.x = x
			other.y = y
		}
	}
}
