
var inst = instance_create_layer(x, y, "Instances", obj_bullet);
inst.direction = image_angle + 90;

alarm[0] = 4 * room_speed;

global.shots_fired++;

