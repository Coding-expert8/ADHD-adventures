
if (choose(0, 1) == 0)
{
	var xx = choose((obj_player.x-683), (obj_player+683));
	var yy = irandom_range(0, room_height);
}
else
{
	var xx = irandom_range((obj_player.x-683), (obj_player+683));
	var yy = choose(0, room_height);
}
instance_create_layer(xx, yy, "Instances", obj_asteroid);
alarm[0] = 4 * 60