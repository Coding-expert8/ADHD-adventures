hp -= 1;   // each shot does 1/3 of health
repeat(10) {
	instance_create_layer(x, y, "Instances", obj_debris);
}


if (hp <= 0) {

	instance_destroy();
}
