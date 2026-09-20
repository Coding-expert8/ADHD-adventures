hp -= 1;
repeat(10) {
	instance_create_layer(x, y, "Instances", obj_debris);
}


if (hp <= 0) {

	instance_destroy();
}
