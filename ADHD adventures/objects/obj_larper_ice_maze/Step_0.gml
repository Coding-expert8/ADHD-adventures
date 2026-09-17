if instance_exists(obj_ship) {
	dir = point_direction(x,y,obj_ship.x,obj_ship.y);
	motion_add(dir,0.05);
}
