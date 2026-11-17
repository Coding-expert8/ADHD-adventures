// arriving through a door (obj_warp): stand on the spawn point it names
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

// back on the map after a minigame a major NPC sent us to (obj_npc): stand where we talked
if (room == room_map and variable_global_exists("return_x") and global.return_x != undefined)
{
	x = global.return_x;
	y = global.return_y;
	global.return_x = undefined;
}

// autosave on every arrival on the map: minigame results, hearts and where the player stands
if (room == room_map) save_game();
