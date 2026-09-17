if room == room_space_rocks
{
if score >= 100000
	{
	room_goto(room_start);
	}
if lives <= 0
	{
	alarm[2] = 60;
	}
}

if global.time = 4 mod 5 { 
	instance_create_layer(obj_ship.x + 50, obj_ship.y + 50, "Instances", obj_asteroid);
}
