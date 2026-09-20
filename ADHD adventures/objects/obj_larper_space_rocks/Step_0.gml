
if instance_exists(obj_ship) {
	dir = point_direction(x, y, obj_ship.x, obj_ship.y);
}
var ax = lengthdir_x(accel, dir);
var ay = lengthdir_y(accel, dir);

vx += ax;
vy += ay;


var spd = point_distance(0, 0, vx, vy);
if (spd > max_speed) {
    vx = vx * (max_speed / spd);
    vy = vy * (max_speed / spd);
}

x += vx;
y += vy;