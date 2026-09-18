if instance_exists(obj_player) {
	dir = point_direction(x,y,obj_ship.x,obj_ship.y);
	if distance_to_object(obj_player) < 300 {
		motion_add(dir,0.01);
	}
	if distance_to_object(obj_player) >= 300 {
		motion_set(dir,0);
	}
}
