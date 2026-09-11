
if (choose(0, 1) == 0)
{
	var xx = choose((0), (room_width));
	var yy = irandom_range(0, room_height);
}
else
{
	var xx = irandom_range(max(0,obj_ship.x-683), obj_ship.x+683);
	var yy = choose(0, room_height);
}
instance_create_layer(xx, yy, "Instances", obj_asteroid);
alarm[0] = 4 * 60

//choose((0), (room_width));
//irandom_range((0), (room_width));
//create wall object, check solid

//choose((obj_ship.x-683), (obj_ship+683));
//irandom_range((obj_ship.x-683), (obj_ship+683));

//var xx = choose(max(0,obj_ship.x-683), obj_ship+683);
