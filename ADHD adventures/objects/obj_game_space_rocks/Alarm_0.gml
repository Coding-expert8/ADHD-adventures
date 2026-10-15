if the_time = 4 mod 5 { 
	number = choose(1,2);
	if number = 1 {
		var xx = choose(obj_ship.x-offset, obj_ship.x+offset);
		var yy = irandom_range(obj_ship.y-offset, obj_ship.y+offset);
	}
	else {
		var yy = choose(obj_ship.y-offset, obj_ship.y+offset);
		var xx = irandom_range(obj_ship.x-offset, obj_ship.x+offset);
	}
	instance_create_layer(xx, yy, "Instances", obj_asteroid);
}
alarm[0] = 60;
the_time++;

